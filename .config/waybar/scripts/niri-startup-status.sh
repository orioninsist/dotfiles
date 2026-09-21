#!/usr/bin/env bash
set -euo pipefail

state_file="${XDG_STATE_HOME:-$HOME/.local/state}/niri-session/enabled"

if [[ -f "$state_file" ]] && grep -qx 'on' "$state_file"; then
    printf '{"text":"󰐊","tooltip":"Startup layout: ON","class":"on"}\n'
else
    printf '{"text":"󰓛","tooltip":"Startup layout: OFF","class":"off"}\n'
fi
