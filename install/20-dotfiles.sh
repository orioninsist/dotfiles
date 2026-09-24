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

# Normalize only helpers that are executed directly. Do not chmod every file
# in these directories; some are data files or scripts intentionally invoked
# through an interpreter.
for helper in \
  "$ROOT/.config/wayland/scripts/fzf-popup" \
  "$ROOT/.config/wayland/scripts/app-launcher" \
  "$ROOT/.config/wayland/scripts/satty-screenshot" \
  "$ROOT/.config/niri/scripts/niri-window-place-once" \
  "$ROOT/.local/bin/path-apps"
do
  [[ -f "$helper" ]] || continue
  chmod u+x "$helper"
done

for f in .bashrc .bash_profile .profile; do
  [[ -e "$ROOT/$f" ]] || continue
  backup_or_link "$ROOT/$f" "$HOME/$f"
done

if [[ -d "$ROOT/.wallpapers" ]]; then
  backup_or_link "$ROOT/.wallpapers" "$HOME/.wallpapers"
fi


echo "==> Applying desktop theme"
CATPPUCCIN_GTK_THEME="catppuccin-mocha-mauve-standard+default"

if command -v gsettings >/dev/null 2>&1; then
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  gsettings set org.gnome.desktop.interface gtk-theme "$CATPPUCCIN_GTK_THEME"
fi
