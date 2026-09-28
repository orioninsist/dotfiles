#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

OUTPUT="$ROOT_DIR/state/metadata/network.txt"

echo "capturing network"

{
    echo "=== Interfaces ==="
    command -v ip >/dev/null 2>&1 && ip addr || true

    echo
    echo "=== Routes ==="
    command -v ip >/dev/null 2>&1 && ip route || true

    echo
    echo "=== DNS ==="
    if [ -f /etc/resolv.conf ]; then
        cat /etc/resolv.conf
    fi

} > "$OUTPUT"
