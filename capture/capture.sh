#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

CONFIG_FILE="$ROOT_DIR/capture/config/default.conf"

source "$CONFIG_FILE"

echo "================================"
echo " DOTFILES CAPTURE"
echo "================================"

echo

echo "Source:"
echo "$SOURCE_HOME"

echo "State:"
echo "$ROOT_DIR/$STATE_DIR"

echo

echo "capture configuration loaded"
