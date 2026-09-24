#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="${DOTFILES_ROOT:?}"

if sudo -n true 2>/dev/null; then
  python3 -m pytest -q "$ROOT/tests"
else
  echo "==> Refreshing sudo credentials for acceptance tests"
  sudo -v
  python3 -m pytest -q "$ROOT/tests"
fi

echo "==> Command parity"
required_commands=(
  git curl niri foot mako wl-copy wl-paste fzf rg jq
  grim slurp ssh vim nvim tesseract easyeffects cliphist
  glow atuin calcurse calibre dust fd fuzzel mpv procs rclone
  syncthing waybar hugo d2 tmux cargo rustc clang convert zenity
  yazi zellij wl-screenrec wl-color-picker bun typst satty eza bat yq
  tree htop btop ncdu zoxide rsync unzip zip git-lfs gh openssl
  gpg age file which lsof strace lspci lsusb host nc starship realesrgan-ncnn-vulkan chatgpt github-copilot-app
)

missing=()
for cmd in "${required_commands[@]}"; do
  command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
done

if (("${#missing[@]}" > 0)); then
  printf 'Missing parity command: %s\n' "${missing[@]}" >&2
  exit 1
fi

echo "==> Bash shell integration"
FLYLINE_SO="$HOME/.local/lib/libflyline.so"
[[ -f "$FLYLINE_SO" ]] || {
  echo "Missing Flyline loadable: $FLYLINE_SO" >&2
  exit 1
}

bash --noprofile --rcfile "$HOME/.bashrc" -ic '
  enable -p | grep -q "^enable flyline$" &&
  type fzf-file-widget >/dev/null 2>&1 &&
  type fzf-flyline-cd-widget >/dev/null 2>&1
' </dev/null || {
  echo "Flyline/FZF Bash integration failed" >&2
  exit 1
}

echo "==> Executable dotfile helpers"
for path in \
  "$HOME/.config/wayland/scripts/fzf-popup" \
  "$HOME/.config/wayland/scripts/app-launcher" \
  "$HOME/.config/wayland/scripts/satty-screenshot" \
  "$HOME/.config/niri/scripts/niri-window-place-once" \
  "$HOME/.local/bin/path-apps"
do
  [[ -x "$path" ]] || {
    echo "Dotfile helper is not executable: $path" >&2
    exit 1
  }
done

echo "==> Niri and display manager"
niri validate --config "$HOME/.config/niri/config.kdl"
test -e /usr/share/wayland-sessions/niri.desktop
systemctl is-enabled --quiet ly@tty2.service
[[ "$(systemctl get-default)" == "graphical.target" ]]

echo "==> Dotfile links"
for path in "$HOME/.config/niri" "$HOME/.config/zellij" "$HOME/.config/systemd"; do
  [[ -e "$path" ]] || { echo "Missing dotfile path: $path" >&2; exit 1; }
done

echo "==> User units"
for unit in ssh-agent.service swayidle.service niri-keyboard-state.service zellij-copy.path; do
  systemctl --user cat "$unit" >/dev/null
  systemctl --user is-enabled --quiet "$unit"
done

echo "==> Projects storage"
SSD_UUID="e2aafb35-8be2-4d13-87a3-f4b644748d59"
ssd_device="$(blkid -U "$SSD_UUID" 2>/dev/null || true)"

if [[ -n "$ssd_device" ]]; then
  [[ "$(findmnt -rn -M /mnt/.data -o SOURCE)" == "$ssd_device" ]] || {
    echo "Projects SSD is not mounted correctly at /mnt/.data" >&2
    exit 1
  }

  [[ "$(findmnt -rn -M /mnt/projects -o SOURCE)" == "$ssd_device[/local/projects]" ]] || {
    echo "Projects bind mount is not correct at /mnt/projects" >&2
    exit 1
  }

  [[ "$(findmnt -rn -M /mnt/.data | wc -l)" -eq 1 ]] || {
    echo "Duplicate /mnt/.data mounts detected" >&2
    exit 1
  }

  [[ "$(findmnt -rn -M /mnt/projects | wc -l)" -eq 1 ]] || {
    echo "Duplicate /mnt/projects mounts detected" >&2
    exit 1
  }
fi

echo "==> Conditional external projects"
[[ ! -d /mnt/projects/knowledge ]] || {
  for unit in knowledge-personal-search.service knowledge-personal-watch.service knowledge-personal-web.service; do
    systemctl --user is-enabled --quiet "$unit"
  done
}

echo "==> Desktop integration"
for cmd in wpctl pactl notify-send gsettings busctl; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "Missing desktop command: $cmd" >&2; exit 1; }
done
for unit in pipewire.socket pipewire-pulse.socket gnome-keyring-daemon.socket; do
  systemctl --user cat "$unit" >/dev/null
done

echo "==> Desktop appearance"
CATPPUCCIN_GTK_THEME="catppuccin-mocha-mauve-standard+default"
CATPPUCCIN_GTK_DIR="$HOME/.local/share/themes/$CATPPUCCIN_GTK_THEME"

[[ "$(gsettings get org.gnome.desktop.interface color-scheme)" == "'prefer-dark'" ]] || {
  echo "GNOME dark color scheme is not enabled" >&2
  exit 1
}

[[ "$(gsettings get org.gnome.desktop.interface gtk-theme)" == "'$CATPPUCCIN_GTK_THEME'" ]] || {
  echo "Catppuccin GTK theme is not active" >&2
  exit 1
}

for gtk in gtk-3.0 gtk-4.0; do
  [[ -f "$CATPPUCCIN_GTK_DIR/$gtk/gtk.css" ]] || {
    echo "Missing Catppuccin $gtk theme" >&2
    exit 1
  }

  grep -Fqx "gtk-theme-name=$CATPPUCCIN_GTK_THEME" \
    "$HOME/.config/$gtk/settings.ini" || {
      echo "$gtk does not select Catppuccin Mocha/Mauve" >&2
      exit 1
    }
done

[[ -L "$HOME/.wallpapers" ]] || {
  echo "~/.wallpapers is not a dotfiles symlink" >&2
  exit 1
}

[[ "$(readlink -f "$HOME/.wallpapers")" == "$ROOT/.wallpapers" ]] || {
  echo "~/.wallpapers does not point to the dotfiles wallpaper directory" >&2
  exit 1
}

[[ -f "$HOME/.wallpapers/sam-ferrara-uNvgvo2cs7k-unsplash.jpg" ]] || {
  echo "Configured wallpaper is missing" >&2
  exit 1
}

echo "==> System service parity"
for unit in bluetooth.service docker.service vnstat.service NetworkManager.service; do
  systemctl cat "$unit" >/dev/null
  systemctl is-enabled --quiet "$unit"
done
for socket in libvirtd.socket libvirtd-ro.socket libvirtd-admin.socket; do
  systemctl cat "$socket" >/dev/null
  systemctl is-enabled --quiet "$socket"
done
if ! systemd-detect-virt --quiet --vm; then
  for unit in thermald.service tuned.service; do
    systemctl is-enabled --quiet "$unit"
  done
fi
if [[ -f "$HOME/.config/rclone/rclone.conf" ]]; then
  systemctl is-enabled --quiet rclone-gdrive.service
  systemctl is-enabled --quiet rclone-gdrive-shared.service
fi

echo "==> Fedora package profile"
if systemd-detect-virt --quiet --vm; then
  rpm -q qemu-guest-agent spice-vdagent acpid >/dev/null
else
  rpm -q libva-intel-media-driver microcode_ctl thermald tuned >/dev/null
fi

echo "Acceptance parity checks passed."

echo
echo "=== SUMMARY ==="
echo "VERIFY_EXIT=0"
echo "NIRI=PASS"
echo "LY=$(systemctl is-enabled ly@tty2.service 2>/dev/null || true)"
echo "SELINUX=$(getenforce 2>/dev/null || echo UNKNOWN)"
echo "FAILED_UNITS=$(systemctl --failed --no-legend | wc -l)"
echo "=== END SUMMARY ==="
