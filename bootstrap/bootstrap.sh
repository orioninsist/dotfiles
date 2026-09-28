#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "================================"
echo " DOTFILES BOOTSTRAP"
echo "================================"

echo

echo "===== CHECK REQUIRED TOOLS ====="

for cmd in git rsync; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "ERROR: $cmd missing"
        exit 1
    fi

    echo "OK: $cmd"
done

echo

echo "===== RESTORE ====="

if [ -x "$ROOT_DIR/restore/restore.sh" ]; then
    "$ROOT_DIR/restore/restore.sh"
else
    echo "restore layer not implemented yet"
fi

echo

echo "===== VERIFY ====="

if [ -x "$ROOT_DIR/verify/verify.sh" ]; then
    "$ROOT_DIR/verify/verify.sh"
else
    echo "verify layer not implemented yet"
fi

echo

echo "===== BOOTSTRAP COMPLETE ====="
