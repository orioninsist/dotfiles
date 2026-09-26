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
  git curl niri kitty mako wl-copy wl-paste fzf rg jq
  grim slurp ssh vim nvim tesseract easyeffects cliphist
  glow atuin calcurse calibre dust fd fuzzel mpv procs rclone
  syncthing waybar hugo d2 tmux cargo rustc clang convert zenity
  yazi zellij wl-screenrec wl-color-picker bun typst satty eza bat yq
  tree htop btop ncdu zoxide rsync unzip zip git-lfs gh openssl
  gpg age file which lsof strace lspci lsusb host nc starship realesrgan-ncnn-vulkan chatgpt github-copilot-app
  arecord amixer ffmpeg wtype notify-send uv
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
  "$HOME/.config/wayland/scripts/path-apps" \
  "$HOME/.config/wayland/scripts/commands/whisper-type"
do
  [[ -x "$path" ]] || {
    echo "Dotfile helper is not executable: $path" >&2
    exit 1
  }
done

echo "==> Niri and display manager"
niri validate --config "$HOME/.config/niri/config.kdl"

echo "==> Whisper voice typing"
WHISPER_PROJECT="$HOME/Media/6-Project/whisper"
WHISPER_PYTHON="$WHISPER_PROJECT/.venv/bin/python"

[[ -d "$WHISPER_PROJECT/.git" ]] || {
  echo "Whisper project checkout is missing: $WHISPER_PROJECT" >&2
  exit 1
}

[[ -x "$WHISPER_PYTHON" ]] || {
  echo "Whisper Python environment is missing: $WHISPER_PYTHON" >&2
  exit 1
}

"$WHISPER_PYTHON" - <<'PYVERIFY'
import torch
import whisper

assert torch.version.cuda is None, f"CUDA Torch installed: {torch.version.cuda}"
assert not torch.cuda.is_available(), "CUDA unexpectedly available"

try:
    import triton
except ImportError:
    pass
else:
    raise SystemExit("Triton unexpectedly installed")

whisper.load_model("small")
print("Whisper small CPU model: PASS")
PYVERIFY

grep -Fq 'Mod+I { spawn "bash" "-lc" "$HOME/.config/wayland/scripts/commands/whisper-type"; }'   "$HOME/.config/niri/binds/system.kdl" || {
    echo "Missing Niri Turkish Whisper binding: Mod+I" >&2
    exit 1
  }

grep -Fq 'Mod+Shift+I { spawn "bash" "-lc" "$HOME/.config/wayland/scripts/commands/whisper-type en"; }'   "$HOME/.config/niri/binds/system.kdl" || {
    echo "Missing Niri English Whisper binding: Mod+Shift+I" >&2
    exit 1
  }

test -e /usr/share/wayland-sessions/niri.desktop
systemctl is-enabled --quiet ly@tty2.service
[[ "$(systemctl get-default)" == "graphical.target" ]]

echo "==> Dotfile links"
for path in "$HOME/.config/niri" "$HOME/.config/zellij" "$HOME/.config/systemd" "$HOME/.config/knowledge"; do
  [[ -e "$path" ]] || { echo "Missing dotfile path: $path" >&2; exit 1; }
done

echo "==> User units"
for unit in ssh-agent.service swayidle.service swaybg.service niri-keyboard-state.service zellij-copy.path; do
  systemctl --user cat "$unit" >/dev/null
  systemctl --user is-enabled --quiet "$unit"
  systemctl --user is-active --quiet "$unit"
done

systemctl --user is-active --quiet graphical-session.target

echo "==> Conditional external projects"
[[ ! -d $HOME/Media/6-Project/knowledge ]] || {
  for unit in knowledge-personal-search.service knowledge-personal-watch.service knowledge-personal-web.service; do
    systemctl --user is-enabled --quiet "$unit"
    systemctl --user is-active --quiet "$unit"
  done
}

echo "==> Desktop integration"
for cmd in wpctl pactl notify-send gsettings busctl; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "Missing desktop command: $cmd" >&2; exit 1; }
done
for unit in pipewire.socket pipewire-pulse.socket gnome-keyring-daemon.socket; do
  systemctl --user cat "$unit" >/dev/null
done


echo "==> GNOME Keyring Secret Service"
busctl --user list | grep -q 'org\.freedesktop\.secrets' || {
  echo "GNOME Keyring Secret Service is unavailable" >&2
  exit 1
}

if command -v code >/dev/null 2>&1; then
  grep -Eq \
    '"password-store"[[:space:]]*:[[:space:]]*"gnome-libsecret"' \
    "$HOME/.vscode/argv.json" || {
      echo "VS Code is not configured to use GNOME Keyring/libsecret" >&2
      exit 1
    }
fi

echo "==> Font stack"

[[ -f "$HOME/.local/share/fonts/GoogleSansCodeNerd/GoogleSansCodeNerdFontMono-Regular.ttf" ]] || {
  echo "GoogleSansCode Nerd Font Mono is missing" >&2
  exit 1
}

mono_family="$(fc-match -f '%{family}\n' monospace)"
[[ "$mono_family" == *"GoogleSansCode Nerd Font Mono"* ]] || {
  echo "Monospace does not resolve to GoogleSansCode Nerd Font Mono: $mono_family" >&2
  exit 1
}

[[ "$(fc-match -f '%{family}\n' emoji | head -1)" == "Noto Color Emoji" ]] || {
  echo "Emoji fallback is not Noto Color Emoji" >&2
  exit 1
}

[[ -f "$HOME/.local/share/fonts/NotoColorEmoji/NotoColorEmoji.ttf" ]] || {
  echo "Noto Color Emoji font file is missing" >&2
  exit 1
}

grep -Fq "font_family      GoogleSansCode Nerd Font Mono" \
  "$HOME/.config/kitty/kitty.conf" || {
    echo "Kitty does not use GoogleSansCode Nerd Font Mono" >&2
    exit 1
  }

echo

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

echo "==> Dolphin and KDE appearance"

rpm -q dolphin kio-extras ffmpegthumbs >/dev/null || {
  echo "Dolphin thumbnail package set is incomplete" >&2
  exit 1
}

if rpm -q nautilus >/dev/null 2>&1; then
  echo "Nautilus must not be installed; Dolphin is the canonical file manager" >&2
  exit 1
fi

[[ "$(xdg-mime query default inode/directory)" == "org.kde.dolphin.desktop" ]] || {
  echo "Dolphin is not the default directory handler" >&2
  exit 1
}

grep -Fqx 'application/x-directory=org.kde.dolphin.desktop'   "$HOME/.config/mimeapps.list" || {
    echo "Dolphin application/x-directory association is missing" >&2
    exit 1
  }

KDE_SCHEME="$HOME/.local/share/color-schemes/CatppuccinMochaMauve.colors"

[[ -f "$KDE_SCHEME" ]] || {
  echo "Catppuccin Mocha Mauve KDE color scheme is missing" >&2
  exit 1
}

grep -Fqx 'ColorScheme=CatppuccinMochaMauve'   "$HOME/.config/kdeglobals" || {
    echo "Catppuccin Mocha Mauve is not the KDE color scheme" >&2
    exit 1
  }

grep -Fqx 'ForegroundNormal=205, 214, 244'   "$HOME/.config/kdeglobals" || {
    echo "Catppuccin KDE foreground colors are not applied" >&2
    exit 1
  }

echo "Dolphin / Catppuccin KDE: PASS"
echo

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

echo "==> Private recovery"

for file in \
  "$ROOT/install/22-recovery.sh" \
  "$ROOT/install/recovery/backup-private.sh" \
  "$ROOT/install/recovery/restore-private.sh" \
  "$ROOT/install/recovery/private-paths.txt" \
  "$ROOT/install/recovery/recipient.txt"
do
  [[ -f "$file" ]] || {
    echo "Missing recovery file: $file" >&2
    exit 1
  }
done

for script in \
  "$ROOT/install/22-recovery.sh" \
  "$ROOT/install/recovery/backup-private.sh" \
  "$ROOT/install/recovery/restore-private.sh"
do
  [[ -x "$script" ]] || {
    echo "Recovery script is not executable: $script" >&2
    exit 1
  }

  bash -n "$script"
done

grep -Eq '^age1[0-9a-z]+$' \
  "$ROOT/install/recovery/recipient.txt" || {
    echo "Invalid age recipient" >&2
    exit 1
  }

for required in \
  '.ssh' \
  '.gnupg' \
  '.config/rclone/rclone.conf'
do
  grep -Fxq "$required" \
    "$ROOT/install/recovery/private-paths.txt" || {
      echo "Missing private recovery path: $required" >&2
      exit 1
    }
done

[[ ! -e "$ROOT/install/recovery/identity.txt" ]] || {
  echo "Private age identity must never exist in the repository" >&2
  exit 1
}

RECOVERY_DIR="$HOME/.config/orion-recovery"

if [[ -f "$RECOVERY_DIR/identity.txt" ]]; then
  [[ "$(stat -c '%a' "$RECOVERY_DIR/identity.txt")" == "600" ]] || {
    echo "Recovery identity permissions must be 600" >&2
    exit 1
  }
fi

if [[ -f "$RECOVERY_DIR/private-backup.tar.age" ]]; then
  [[ "$(stat -c '%a' "$RECOVERY_DIR/private-backup.tar.age")" == "600" ]] || {
    echo "Encrypted recovery backup permissions must be 600" >&2
    exit 1
  }
fi

echo "Private recovery: PASS"
echo

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
  echo "==> Read-only Google Drive mounts"

  for unit in rclone-gdrive.service rclone-gdrive-shared.service; do
    systemctl --user cat "$unit" >/dev/null
    systemctl --user is-enabled --quiet "$unit"
  done

  gdrive_unit="$(systemctl --user cat rclone-gdrive.service)"
  shared_unit="$(systemctl --user cat rclone-gdrive-shared.service)"

  grep -q -- '--read-only' <<<"$gdrive_unit"
  grep -q -- '--vfs-cache-mode off' <<<"$gdrive_unit"
  grep -q -- '%h/GoogleDrive' <<<"$gdrive_unit"

  grep -q -- '--read-only' <<<"$shared_unit"
  grep -q -- '--vfs-cache-mode off' <<<"$shared_unit"
  grep -q -- '--drive-shared-with-me' <<<"$shared_unit"
  grep -q -- '%h/GoogleDrive-Shared' <<<"$shared_unit"
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
