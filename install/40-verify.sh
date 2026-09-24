#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="${DOTFILES_ROOT:?}"

python3 -m pytest -q "$ROOT/tests"

echo "==> Command parity"
required_commands=(
  git curl niri foot mako wl-copy wl-paste fzf rg jq
  grim slurp ssh vim nvim tesseract easyeffects cliphist
  glow atuin calcurse calibre dust fd fuzzel mpv procs rclone
  syncthing waybar hugo d2 tmux cargo rustc clang convert zenity
  yazi zellij wl-screenrec wl-color-picker bun typst eza bat yq
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

echo "==> Conditional external projects"
[[ ! -d /mnt/local/projects/knowledge ]] || {
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
