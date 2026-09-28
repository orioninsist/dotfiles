#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

OUTPUT="$ROOT_DIR/state/metadata/packages.txt"

echo "capturing packages"

if command -v pacman >/dev/null 2>&1; then
    pacman -Q > "$OUTPUT"

elif command -v dpkg >/dev/null 2>&1; then
    dpkg --get-selections > "$OUTPUT"

elif command -v rpm >/dev/null 2>&1; then
    rpm -qa > "$OUTPUT"

else
    echo "no supported package manager"
    exit 1
fi
