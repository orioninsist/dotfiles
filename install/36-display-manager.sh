#!/usr/bin/env bash
set -Eeuo pipefail

source /etc/os-release
[[ "${ID:-}" == "fedora" ]] || { echo "Fedora required" >&2; exit 1; }

command -v ly >/dev/null || { echo "ly is required" >&2; exit 1; }

# Fedora's ly package may not ship a native ly.service unit. Create a local
# systemd display-manager unit around the packaged /usr/bin/ly binary.
sudo install -d -m 0755 /etc/systemd/system
sudo tee /etc/systemd/system/ly.service >/dev/null <<'UNIT'
[Unit]
Description=LY TUI Display Manager
After=systemd-user-sessions.service plymouth-quit-wait.service
Conflicts=getty@tty2.service

[Service]
Type=simple
ExecStart=/usr/bin/ly
StandardInput=tty
TTYPath=/dev/tty2
TTYReset=yes
TTYVHangup=yes
TTYVTDisallocate=yes
Restart=always
RestartSec=1

[Install]
Alias=display-manager.service
WantedBy=graphical.target
UNIT

sudo systemctl daemon-reload
sudo systemctl disable gdm.service sddm.service lightdm.service 2>/dev/null || true
sudo systemctl enable ly.service
sudo systemctl set-default graphical.target

test -e /usr/share/wayland-sessions/niri.desktop || {
  echo "Missing Niri Wayland session: /usr/share/wayland-sessions/niri.desktop" >&2
  exit 1
}

echo "Display manager configured: ly.service"
