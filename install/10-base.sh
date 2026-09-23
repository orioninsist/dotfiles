#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="${DOTFILES_ROOT:?}"

mapfile -t pkgs < <(awk -F '\t' '$1=="dnf"{print $2}' "$ROOT/install/manifest.tsv")

if (("${#pkgs[@]}" == 0)); then
  echo "No Fedora packages found in install/manifest.tsv" >&2
  exit 1
fi

sudo dnf -y upgrade --refresh
sudo dnf -y install "${pkgs[@]}"
