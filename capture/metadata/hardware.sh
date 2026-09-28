#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

OUTPUT="$ROOT_DIR/state/metadata/hardware.txt"

echo "capturing hardware"

{
    echo "=== CPU ==="
    command -v lscpu >/dev/null 2>&1 && lscpu || true

    echo
    echo "=== PCI ==="
    command -v lspci >/dev/null 2>&1 && lspci || true

    echo
    echo "=== USB ==="
    command -v lsusb >/dev/null 2>&1 && lsusb || true

} > "$OUTPUT"
