#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${DOTFILES_ROOT:?}"
USER_NAME="${USER:?}"
SYSTEMD_DIR="/etc/systemd/system"

install_rclone_unit() {
  local source="$1"
  local target="$2"

  sudo install -m 0644 "$source" "$target"
}

if [[ -f "$HOME/.config/rclone/rclone.conf" ]]; then
  echo "==> Installing rclone system services"
  sudo mkdir -p /mnt/gdrive /mnt/gdrive-shared

  # system services cannot expand %h the way user services do; render the current home explicitly.
  sed "s|%h|$HOME|g; s|User=%i|User=$USER_NAME|; s|Group=%i|Group=$USER_NAME|"     "$ROOT/install/systemd/rclone-gdrive.service" | sudo tee "$SYSTEMD_DIR/rclone-gdrive.service" >/dev/null

  sed "s|%h|$HOME|g; s|User=%i|User=$USER_NAME|; s|Group=%i|Group=$USER_NAME|"     "$ROOT/install/systemd/rclone-gdrive-shared.service" | sudo tee "$SYSTEMD_DIR/rclone-gdrive-shared.service" >/dev/null

  sudo systemctl daemon-reload
  sudo systemctl enable rclone-gdrive.service rclone-gdrive-shared.service
else
  echo "INFO rclone config missing; rclone mount services remain disabled."
fi

echo "==> Enabling Arch-parity Fedora system services"
for unit in bluetooth.service docker.service iwd.service vnstat.service; do
  if systemctl cat "$unit" >/dev/null 2>&1; then
    sudo systemctl enable "$unit"
  else
    echo "INFO system unit unavailable: $unit"
  fi
done

if ! systemd-detect-virt --quiet --vm; then
  for unit in thermald.service tuned.service; do
    if systemctl cat "$unit" >/dev/null 2>&1; then
      sudo systemctl enable "$unit"
    else
      echo "INFO physical system unit unavailable: $unit"
    fi
  done
fi

for socket in libvirtd.socket libvirtd-ro.socket libvirtd-admin.socket; do
  if systemctl cat "$socket" >/dev/null 2>&1; then
    sudo systemctl enable "$socket"
  fi
done
