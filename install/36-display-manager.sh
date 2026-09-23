#!/usr/bin/env bash
set -Eeuo pipefail

source /etc/os-release
[[ "${ID:-}" == "fedora" ]] || { echo "Fedora required" >&2; exit 1; }

command -v ly >/dev/null || { echo "ly is required" >&2; exit 1; }

sudo systemctl disable --now gdm.service sddm.service lightdm.service 2>/dev/null || true
sudo systemctl enable ly.service
sudo systemctl set-default graphical.target

test -e /usr/share/wayland-sessions/niri.desktop || {
  echo "Missing Niri Wayland session: /usr/share/wayland-sessions/niri.desktop" >&2
  exit 1
}

echo "Display manager configured: ly.service"
