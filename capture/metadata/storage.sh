#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

OUTPUT="$ROOT_DIR/state/metadata/storage.txt"

echo "capturing storage"

{
    echo "=== Block Devices ==="
    command -v lsblk >/dev/null 2>&1 && lsblk || true

    echo
    echo "=== Filesystems ==="
    df -h

    echo
    echo "=== Mounts ==="
    mount

} > "$OUTPUT"
