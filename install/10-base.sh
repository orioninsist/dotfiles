#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="${DOTFILES_ROOT:?}"

mapfile -t pkgs < <(awk -F '\t' '$1=="dnf"{print $2}' "$ROOT/install/manifest.tsv")
(("${#pkgs[@]}" > 0)) || { echo "No Fedora packages found in install/manifest.tsv" >&2; exit 1; }

echo "Checking ${#pkgs[@]} Fedora packages..."
missing=()
index=0
for pkg in "${pkgs[@]}"; do
  ((index += 1))
  printf '  [%d/%d] %s\n' "$index" "${#pkgs[@]}" "$pkg"
  dnf -q repoquery --available "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
done

if (("${#missing[@]}" > 0)); then
  printf 'Unavailable Fedora package: %s\n' "${missing[@]}" >&2
  exit 1
fi

dnf_retry() {
  local attempt=1
  local max_attempts=3
  while true; do
    echo "DNF attempt $attempt/$max_attempts: $*"
    if sudo dnf "$@"; then
      return 0
    fi
    if ((attempt >= max_attempts)); then
      echo "DNF failed after $max_attempts attempts." >&2
      return 1
    fi
    echo "DNF failed; retrying in 5 seconds..."
    sleep 5
    ((attempt += 1))
  done
}

echo
echo "Refreshing and upgrading Fedora packages..."
dnf_retry -y upgrade --refresh

echo
echo "Installing required Fedora packages..."
dnf_retry -y install "${pkgs[@]}"

echo "Fedora package phase complete."
