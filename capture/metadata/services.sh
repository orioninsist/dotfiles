#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

OUTPUT="$ROOT_DIR/state/metadata/services.txt"

echo "capturing services"

if command -v systemctl >/dev/null 2>&1; then
    systemctl list-unit-files --type=service > "$OUTPUT"
else
    echo "systemd not available"
    exit 1
fi
