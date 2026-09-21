#!/usr/bin/env bash
set -euo pipefail

session="$HOME/.config/niri/scripts/niri-session"

"$session" toggle >/dev/null

if command -v pkill >/dev/null 2>&1; then
    pkill -RTMIN+8 waybar 2>/dev/null || true
fi
