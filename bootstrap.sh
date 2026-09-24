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
  fedora) ;;
  *) echo "bootstrap.sh targets Fedora only (detected: ${ID:-unknown})." >&2; exit 2 ;;
esac

if [[ "${VERSION_ID:-}" != "44" ]]; then
  echo "bootstrap.sh is validated for Fedora 44 only (detected: ${VERSION_ID:-unknown})." >&2
  exit 3
fi

for step in \
  install/05-preflight.sh \
  install/10-base.sh \
  install/12-external-tools.sh \
  install/13-vendor-apps.sh \
  install/15-fonts.sh \
  install/20-dotfiles.sh \
  install/25-storage.sh \
  install/27-whisper.sh \
  install/30-services.sh \
  install/32-system-services.sh \
  install/35-fedora-qemu-guest.sh \
  install/36-display-manager.sh \
  install/40-verify.sh
do
  echo "==> $step"
  bash "$ROOT/$step"
done
