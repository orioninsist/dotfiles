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
  gpg age file which lsof strace lspci lsusb host nc starship
)

missing=()
for cmd in "${required_commands[@]}"; do
  command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
done

if (("${#missing[@]}" > 0)); then
  printf 'Missing parity command: %s\n' "${missing[@]}" >&2
  exit 1
fi

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

echo "==> Fedora package profile"
if systemd-detect-virt --quiet --vm; then
  rpm -q qemu-guest-agent spice-vdagent acpid >/dev/null
else
  rpm -q intel-media-driver microcode_ctl thermald tuned >/dev/null
fi

echo "Acceptance parity checks passed."
