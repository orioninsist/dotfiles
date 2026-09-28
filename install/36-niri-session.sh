#!/usr/bin/env bash
set -Eeuo pipefail

command -v niri-session >/dev/null || {
  echo "niri-session is required" >&2
  exit 1
}

test -e /usr/share/wayland-sessions/niri.desktop || {
  echo "Missing Niri Wayland session" >&2
  exit 1
}

grep -Eq '^Exec=(/usr/(s)?bin/)?niri-session([[:space:]]|$)' \
  /usr/share/wayland-sessions/niri.desktop || {
  echo "Invalid Niri session entry" >&2
  exit 1
}

echo "Niri session available."
echo "Start manually from TTY with: niri-session"
