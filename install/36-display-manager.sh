#!/usr/bin/env bash
set -Eeuo pipefail

source /etc/os-release
[[ "${ID:-}" == "fedora" ]] || { echo "Fedora required" >&2; exit 1; }

command -v ly >/dev/null || { echo "ly is required" >&2; exit 1; }
command -v niri-session >/dev/null || { echo "niri-session is required" >&2; exit 1; }

test -e /usr/lib/systemd/system/ly@.service || {
  echo "Missing Fedora Ly template unit: /usr/lib/systemd/system/ly@.service" >&2
  exit 1
}

test -e /usr/share/wayland-sessions/niri.desktop || {
  echo "Missing Niri Wayland session: /usr/share/wayland-sessions/niri.desktop" >&2
  exit 1
}

grep -Eq '^Exec=(/usr/bin/)?niri-session([[:space:]]|$)' /usr/share/wayland-sessions/niri.desktop || {
  echo "Invalid Niri session Exec entry" >&2
  exit 1
}

sudo install -d -m 0755 /etc/ly/custom-sessions
sudo tee /etc/ly/custom-sessions/niri.desktop >/dev/null <<'DESKTOP'
[Desktop Entry]
Name=Niri
Comment=A scrollable-tiling Wayland compositor
Exec=/usr/bin/niri-session
Type=Application
DesktopNames=niri
DESKTOP

sudo systemctl disable gdm.service sddm.service lightdm.service 2>/dev/null || true
sudo systemctl disable getty@tty2.service 2>/dev/null || true
sudo systemctl enable ly@tty2.service
sudo systemctl set-default graphical.target

echo "Display manager configured: ly@tty2.service"
echo "Niri session entrypoint: /usr/bin/niri-session"
