#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

OUTPUT="$ROOT_DIR/state/metadata/kernel.txt"

echo "capturing kernel"

{
    echo "=== Kernel ==="
    uname -a

    echo
    echo "=== OS ==="
    if [ -f /etc/os-release ]; then
        cat /etc/os-release
    fi

    echo
    echo "=== Architecture ==="
    uname -m

} > "$OUTPUT"
