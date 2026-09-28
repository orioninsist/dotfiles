#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

CONFIG_FILE="$ROOT_DIR/capture/config/default.conf"

source "$CONFIG_FILE"

DEST="$ROOT_DIR/$STATE_DIR"
LOG_FILE="$ROOT_DIR/state/logs/capture.log"

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

echo "capture running"
mkdir -p "$DEST"

rsync \
$RSYNC_OPTIONS \
$RSYNC_PROGRESS \
--filter="merge $ROOT_DIR/$RSYNC_FILTER" \
"$SOURCE_HOME/" \
"$DEST/" 2>&1 | tee -a "$LOG_FILE"


echo
echo "capturing metadata"

"$ROOT_DIR/capture/metadata/run.sh"
