#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="${DOTFILES_ROOT:?}"

mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/.local/share"

backup_or_link() {
  local src="$1" dst="$2"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    local backup="${dst}.before-dotfiles-$(date +%Y%m%d-%H%M%S)"
    mv "$dst" "$backup"
    echo "BACKUP: $dst -> $backup"
  fi
  ln -sfn "$src" "$dst"
}

for p in "$ROOT"/.config/*; do
  [[ -e "$p" ]] || continue
  backup_or_link "$p" "$HOME/.config/${p##*/}"
done

for p in "$ROOT"/.local/bin/*; do
  [[ -f "$p" ]] || continue
  backup_or_link "$p" "$HOME/.local/bin/${p##*/}"
done

for f in .bashrc .bash_profile .profile; do
  [[ -e "$ROOT/$f" ]] || continue
  backup_or_link "$ROOT/$f" "$HOME/$f"
done

if [[ -d "$ROOT/.wallpapers" ]]; then
  backup_or_link "$ROOT/.wallpapers" "$HOME/.wallpapers"
fi
