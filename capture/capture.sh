#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

CONFIG_FILE="$ROOT_DIR/capture/config/default.conf"

source "$CONFIG_FILE"

DEST="$ROOT_DIR/$STATE_DIR"

echo "================================"
echo " DOTFILES CAPTURE"
echo "================================"

echo

echo "Source:"
echo "$SOURCE_HOME"

echo "Destination:"
echo "$DEST"

echo

echo "Rsync options:"
echo "$RSYNC_OPTIONS"

echo

echo "capture dry-run ready"

rsync $RSYNC_OPTIONS $RSYNC_PROGRESS --dry-run "$SOURCE_HOME/" "$DEST/"

