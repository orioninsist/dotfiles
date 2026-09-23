#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_ROOT="$ROOT"

if [[ $EUID -eq 0 ]]; then
  echo "Run bootstrap as the target user, not root." >&2
  exit 1
fi

source /etc/os-release
case "${ID:-}" in
  debian) ;;
  *) echo "bootstrap.sh currently targets Debian only (detected: ${ID:-unknown})." >&2; exit 2 ;;
esac

for step in   install/10-base.sh   install/20-dotfiles.sh   install/30-services.sh   install/40-verify.sh
do
  echo "==> $step"
  bash "$ROOT/$step"
done
