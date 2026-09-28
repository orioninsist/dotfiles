#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

OUTPUT="$ROOT_DIR/state/metadata/users.txt"

echo "capturing users"

cut -d: -f1,3 /etc/passwd > "$OUTPUT"
