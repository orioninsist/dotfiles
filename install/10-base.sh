#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="${DOTFILES_ROOT:?}"

mapfile -t pkgs < <(awk -F '	' '$1=="dnf"{print $2}' "$ROOT/install/manifest.tsv")
(("${#pkgs[@]}" > 0)) || { echo "No Fedora packages found in install/manifest.tsv" >&2; exit 1; }

missing=()
for pkg in "${pkgs[@]}"; do
  dnf -q repoquery --available "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
done

if (("${#missing[@]}" > 0)); then
  printf 'Unavailable Fedora package: %s
' "${missing[@]}" >&2
  exit 1
fi

sudo dnf -y upgrade --refresh
sudo dnf -y install "${pkgs[@]}"
