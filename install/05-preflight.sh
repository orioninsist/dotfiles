#!/usr/bin/env bash
set -Eeuo pipefail

source /etc/os-release
[[ "${ID:-}" == "fedora" ]] || { echo "Fedora required" >&2; exit 1; }
[[ "${VERSION_ID:-}" == "44" ]] || { echo "Fedora 44 required" >&2; exit 1; }

command -v sudo >/dev/null || { echo "sudo is required" >&2; exit 1; }
command -v dnf >/dev/null || { echo "dnf is required" >&2; exit 1; }

if [[ "$HOME" != "/home/murat" ]]; then
  echo "Target account must currently be murat because several application/session rules still assume that account identity." >&2
  exit 1
fi

mkdir -p "$HOME/.cache"
