#!/usr/bin/env bash
set -Eeuo pipefail

# Reconcile the current Fedora machine into the repository's declarative state.
# This intentionally excludes secrets, home-directory data, Google Drive, and rclone.

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
STATE_DIR="$ROOT/state"
LOCK_FILE="/tmp/orion-system-state-sync-${UID}.lock"
NO_PUSH=0
DRY_RUN=0

usage() {
  printf 'Usage: %s [--no-push] [--dry-run]\n' "$0"
}

for arg in "$@"; do
  case "$arg" in
    --no-push) NO_PUSH=1 ;;
    --dry-run) DRY_RUN=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ERROR: unknown argument: $arg" >&2; usage >&2; exit 2 ;;
  esac
done

command -v git >/dev/null || { echo "ERROR: git is required." >&2; exit 1; }
command -v rpm >/dev/null || { echo "ERROR: rpm is required." >&2; exit 1; }

if ! mkdir "$LOCK_FILE" 2>/dev/null; then
  echo "INFO: another system-state sync is already running."
  exit 0
fi
trap 'rmdir "$LOCK_FILE" 2>/dev/null || true' EXIT

# Never reconcile state on top of unrelated local work.
if [[ -n "$(git -C "$ROOT" status --porcelain --untracked-files=normal)" ]]; then
  echo "INFO: repository has local changes; system-state sync skipped."
  exit 0
fi

# Synchronize safely with origin before generating a state commit.
git -C "$ROOT" fetch origin

branch="$(git -C "$ROOT" symbolic-ref --quiet --short HEAD || true)"
if [[ -z "$branch" ]]; then
  echo "ERROR: repository is in detached HEAD state." >&2
  exit 1
fi

remote_ref="origin/$branch"

if ! git -C "$ROOT" rev-parse --verify "$remote_ref" >/dev/null 2>&1; then
  echo "ERROR: remote branch $remote_ref does not exist." >&2
  exit 1
fi

local_sha="$(git -C "$ROOT" rev-parse HEAD)"
remote_sha="$(git -C "$ROOT" rev-parse "$remote_ref")"
base_sha="$(git -C "$ROOT" merge-base HEAD "$remote_ref")"

if [[ "$local_sha" == "$remote_sha" ]]; then
  :
elif [[ "$local_sha" == "$base_sha" ]]; then
  git -C "$ROOT" merge --ff-only "$remote_ref"
elif [[ "$remote_sha" == "$base_sha" ]]; then
  :
else
  echo "ERROR: local and $remote_ref have diverged; sync skipped." >&2
  exit 1
fi

mkdir -p "$STATE_DIR/packages" "$STATE_DIR/services"

rpm -qa --qf '%{NAME}\n' | LC_ALL=C sort -u > "$STATE_DIR/packages/rpm.txt"

if command -v flatpak >/dev/null 2>&1; then
  flatpak list --app --columns=application 2>/dev/null | LC_ALL=C sort -u > "$STATE_DIR/packages/flatpak.txt" || :
else
  : > "$STATE_DIR/packages/flatpak.txt"
fi

systemctl list-unit-files --type=service --state=enabled --no-legend --no-pager 2>/dev/null |
  awk '{print $1}' | LC_ALL=C sort -u > "$STATE_DIR/services/system-enabled.txt" || :

systemctl --user list-unit-files --type=service --state=enabled --no-legend --no-pager 2>/dev/null |
  awk '{print $1}' | LC_ALL=C sort -u > "$STATE_DIR/services/user-enabled.txt" || :

{
  printf 'hostname=%s\n' "$(hostname)"
  printf 'kernel=%s\n' "$(uname -srmo)"
  if [[ -r /etc/os-release ]]; then
    # Keep only stable identity fields; do not copy arbitrary environment data.
    awk -F= '$1 ~ /^(ID|VERSION_ID|PRETTY_NAME)$/ {print}' /etc/os-release
  fi
} > "$STATE_DIR/system.txt"

git -C "$ROOT" add state

if git -C "$ROOT" diff --cached --quiet; then
  echo "OK: system state is already current."
  exit 0
fi

git -C "$ROOT" diff --cached --stat

if ((DRY_RUN)); then
  echo "DRY RUN: no commit or push performed."
  git -C "$ROOT" reset >/dev/null
  exit 0
fi

git -C "$ROOT" commit -m "chore(state): reconcile current Fedora system"

if ((NO_PUSH)); then
  echo "OK: state committed locally; push skipped (--no-push)."
  exit 0
fi

git -C "$ROOT" push origin HEAD
echo "OK: system state committed and pushed to origin."
