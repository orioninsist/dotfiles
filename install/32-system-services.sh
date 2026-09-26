#!/usr/bin/env bash
set -Eeuo pipefail

echo "==> Enabling Arch-parity Fedora system services"
for unit in bluetooth.service docker.service vnstat.service; do
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

# Fedora owns networking through NetworkManager. Do not recreate Arch's
# systemd-networkd+iwd topology unless a Fedora-specific NM iwd backend is configured.
if systemctl cat NetworkManager.service >/dev/null 2>&1; then
  sudo systemctl enable NetworkManager.service
fi
