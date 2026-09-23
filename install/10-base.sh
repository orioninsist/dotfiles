#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="${DOTFILES_ROOT:?}"
mapfile -t pkgs < <(awk -F '\t' '$1=="apt"{print $2}' "$ROOT/install/manifest.tsv")
sudo apt-get update
sudo apt-get install -y "${pkgs[@]}"
