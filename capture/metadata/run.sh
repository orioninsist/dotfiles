#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

METADATA_DIR="$ROOT_DIR/capture/metadata"

echo "================================"
echo " METADATA CAPTURE"
echo "================================"

for script in \
    users.sh \
    packages.sh \
    services.sh \
    hardware.sh \
    kernel.sh \
    network.sh \
    storage.sh
do
    echo
    echo "running: $script"
    "$METADATA_DIR/$script"
done

echo
echo "metadata capture completed"
