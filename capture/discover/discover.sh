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

# .config altındaki uygulamalar
if [ -d "$HOME_DIR/.config" ]; then

    for dir in "$HOME_DIR/.config"/*; do

        [ -e "$dir" ] || continue

        name="${dir#$HOME_DIR/}"

        echo "$name" >> "$OUTPUT"
        echo "found: $name"

    done

fi


# Tekil dosya ve dizinler

for path in \
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
