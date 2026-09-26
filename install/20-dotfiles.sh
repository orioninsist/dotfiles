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

# Expose repository-managed command and application wrappers through PATH.
for dir in \
  "$ROOT/.local/bin" \
  "$ROOT/.config/wayland/scripts/commands" \
  "$ROOT/.config/wayland/apps"
do
  [[ -d "$dir" ]] || continue
  for p in "$dir"/*; do
    [[ -f "$p" ]] || continue
    backup_or_link "$p" "$HOME/.local/bin/${p##*/}"
  done
done

# Normalize only helpers that are executed directly. Do not chmod every file
# in these directories; some are data files or scripts intentionally invoked
# through an interpreter.
for helper in \
  "$ROOT/.config/wayland/scripts/fzf-popup" \
  "$ROOT/.config/wayland/scripts/app-launcher" \
  "$ROOT/.config/wayland/scripts/satty-screenshot" \
  "$ROOT/.config/niri/scripts/niri-window-place-once" \
  "$ROOT/.config/wayland/scripts/path-apps"
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

# Install repository-managed KDE color schemes without duplicating them.
if [[ -d "$ROOT/.local/share/color-schemes" ]]; then
  mkdir -p "$HOME/.local/share/color-schemes"
  for p in "$ROOT"/.local/share/color-schemes/*; do
    [[ -f "$p" ]] || continue
    backup_or_link "$p" "$HOME/.local/share/color-schemes/${p##*/}"
  done
fi


echo "==> Applying desktop theme"
CATPPUCCIN_GTK_THEME="catppuccin-mocha-mauve-standard+default"

if command -v gsettings >/dev/null 2>&1; then
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  gsettings set org.gnome.desktop.interface gtk-theme "$CATPPUCCIN_GTK_THEME"
fi

rm -f "$HOME/.cache/orion-launcher/path-commands"

if command -v calibre-debug >/dev/null 2>&1; then
  env -u CALIBRE_USE_SYSTEM_THEME -u QT_QPA_PLATFORMTHEME -u QT_STYLE_OVERRIDE \
    CALIBRE_CONFIG_DIRECTORY="$HOME/.config/calibre" \
    calibre-debug -c "from calibre.gui2 import gprefs; gprefs['color_palette']='dark'; gprefs['ui_style']='calibre'; gprefs.commit()"
fi

# Generate the machine-local Knowledge workspace configuration. Knowledge
# currently requires an absolute workspace root, so expand HOME at install time.
if [[ -f "$ROOT/.config/knowledge/workspaces.toml.example" ]]; then
  mkdir -p "$ROOT/.config/knowledge"
  sed "s#__HOME__#$HOME#g" \
    "$ROOT/.config/knowledge/workspaces.toml.example" \
    > "$ROOT/.config/knowledge/workspaces.toml"
  chmod 600 "$ROOT/.config/knowledge/workspaces.toml"
fi
