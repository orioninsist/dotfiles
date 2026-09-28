#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

CONFIG_FILE="$ROOT_DIR/restore/config/default.conf"

source "$CONFIG_FILE"

SOURCE="$ROOT_DIR/$SOURCE_STATE"

LOG_FILE="$ROOT_DIR/state/logs/restore.log"

echo "================================"
echo " DOTFILES RESTORE"
echo "================================"

echo

if [ ! -d "$SOURCE" ]; then
    echo "ERROR: restore source missing"
    exit 1
fi

echo "Source:"
echo "$SOURCE"

echo "Target:"
echo "$TARGET_HOME"

echo

mkdir -p "$TARGET_HOME"

echo "restore running"

rsync $RSYNC_OPTIONS "$SOURCE/" "$TARGET_HOME/" 2>&1 | tee -a "$LOG_FILE"

