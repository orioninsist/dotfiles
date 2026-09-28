#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

OUTPUT="$ROOT_DIR/state/discovered/files.list"

HOME_DIR="$HOME"

echo "================================"
echo " DOTFILES DISCOVERY"
echo "================================"

mkdir -p "$(dirname "$OUTPUT")"

> "$OUTPUT"

echo "discovering config directories"

for path in \
    ".config" \
    ".local/bin" \
    ".ssh/config" \
    ".gitconfig" \
    ".zshrc" \
    ".bashrc" \
    ".tmux.conf"
do

    if [ -e "$HOME_DIR/$path" ]; then
        echo "$path" >> "$OUTPUT"
        echo "found: $path"
    fi

done

echo
echo "discovery completed"
echo "output:"
echo "$OUTPUT"
