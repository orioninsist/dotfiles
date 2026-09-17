#!/usr/bin/env bash

set -euo pipefail

INTERNAL="eDP-1"
EXTERNAL="HDMI-A-1"

notify() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -a "Sway" "Display switched" "$1"
    fi
}

move_workspaces() {
    local target="$1"

    swaymsg -t get_workspaces -r |
        jq -r '.[].name' |
        while IFS= read -r workspace; do
            swaymsg workspace "$workspace" >/dev/null
            swaymsg move workspace to output "$target" >/dev/null
        done
}

external_active="$(
    swaymsg -t get_outputs -r |
        jq -r --arg output "$EXTERNAL" '.[] | select(.name == $output) | .active'
)"

if [[ "$external_active" == "true" ]]; then
    swaymsg output "$INTERNAL" enable >/dev/null
    move_workspaces "$INTERNAL"
    swaymsg output "$EXTERNAL" disable >/dev/null
    swaymsg focus output "$INTERNAL" >/dev/null
    notify "ThinkPad display active"
else
    swaymsg output "$EXTERNAL" enable >/dev/null
    move_workspaces "$EXTERNAL"
    swaymsg output "$INTERNAL" disable >/dev/null
    swaymsg focus output "$EXTERNAL" >/dev/null
    notify "ASUS VN247 active"
fi
