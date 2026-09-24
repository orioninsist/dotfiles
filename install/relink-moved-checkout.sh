#!/usr/bin/env bash
set -Eeuo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"

relink() {
  local source="$1" destination="$2" previous
  [[ -L "$destination" && -e "$source" ]] || return 0
  previous="$(readlink -- "$destination")"
  [[ "$previous" == "$source" ]] && return 0
  # Only repair links that point to the same file in a previous dotfiles checkout.
  [[ "$previous" == */dotfiles/"${source#"$root"/}" ]] || return 0
  ln -sfn -- "$source" "$destination"
  printf 'RELINK: %s -> %s\n' "$destination" "$source"
}

for source in "$root"/.config/*; do
  [[ -e "$source" ]] || continue
  relink "$source" "$HOME/.config/${source##*/}"
done
for source in "$root"/.local/bin/*; do
  [[ -f "$source" ]] || continue
  relink "$source" "$HOME/.local/bin/${source##*/}"
done
for name in .bashrc .bash_profile .profile .wallpapers; do
  relink "$root/$name" "$HOME/$name"
done
