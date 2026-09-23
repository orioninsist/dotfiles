#!/usr/bin/env bash
set -Eeuo pipefail

source /etc/os-release
[[ "${ID:-}" == "fedora" ]] || { echo "Fedora required" >&2; exit 1; }

command -v ly >/dev/null || { echo "ly is required" >&2; exit 1; }

# Fedora 44 ships Ly as template units: ly@.service and ly-kmsconvt@.service.
# Use the packaged systemd integration on tty2 instead of inventing ly.service.
test -e /usr/lib/systemd/system/ly@.service || {
  echo "Missing Fedora Ly template unit: /usr/lib/systemd/system/ly@.service" >&2
  exit 1
}

sudo systemctl disable gdm.service sddm.service lightdm.service 2>/dev/null || true
sudo systemctl disable getty@tty2.service 2>/dev/null || true
sudo systemctl enable ly@tty2.service
sudo systemctl set-default graphical.target

test -e /usr/share/wayland-sessions/niri.desktop || {
  echo "Missing Niri Wayland session: /usr/share/wayland-sessions/niri.desktop" >&2
  exit 1
}

echo "Display manager configured: ly@tty2.service"
