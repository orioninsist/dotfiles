#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_ROOT="$ROOT"

echo "== Fedora dotfiles installer =="
echo "Repo: $ROOT"

bash "$ROOT/install/05-preflight.sh"
bash "$ROOT/install/10-base.sh"
bash "$ROOT/install/20-dotfiles.sh"
bash "$ROOT/install/30-services.sh"
bash "$ROOT/install/35-fedora-qemu-guest.sh"
bash "$ROOT/install/40-verify.sh"

echo
echo "INSTALL COMPLETE"
echo "Reboot recommended."
