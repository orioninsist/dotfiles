#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

CONFIG_FILE="$ROOT_DIR/restore/config/default.conf"

source "$CONFIG_FILE"

SOURCE="$ROOT_DIR/$SOURCE_STATE"

echo "================================"
echo " DOTFILES RESTORE"
echo "================================"

echo

echo "Source:"
echo "$SOURCE"

echo "Target:"
echo "$TARGET_HOME"

echo

echo "restore configuration loaded"

