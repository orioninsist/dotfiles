#!/usr/bin/env bash
set -Eeuo pipefail

source /etc/os-release
[[ "${ID:-}" == "fedora" ]] || { echo "Fedora required" >&2; exit 1; }
[[ "${VERSION_ID:-}" == "44" ]] || { echo "Fedora 44 required" >&2; exit 1; }

command -v sudo >/dev/null || { echo "sudo is required" >&2; exit 1; }
command -v dnf >/dev/null || { echo "dnf is required" >&2; exit 1; }

mkdir -p "$HOME/.cache"
