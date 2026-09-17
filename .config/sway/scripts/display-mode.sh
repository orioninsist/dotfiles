#!/usr/bin/env bash

set -euo pipefail

INTERNAL="eDP-1"
EXTERNAL="HDMI-A-1"
MODE="${1:-}"

notify_mode() {
    notify-send -a "Sway" "Display mode" "$1" 2>/dev/null || true
}

move_all_to() {
    local target="$1"

    swaymsg -t get_workspaces -r |
        jq -r '.[].name' |
        while IFS= read -r workspace; do
            swaymsg "workspace \"$workspace\"; move workspace to output \"$target\"" >/dev/null
        done
}

restore_dual_layout() {
    swaymsg -t get_workspaces -r |
        jq -r '.[].name' |
        while IFS= read -r workspace; do
            case "$workspace" in
                1|2|3|4|5)
                    swaymsg "workspace $workspace; move workspace to output \"$EXTERNAL\"" >/dev/null
                    ;;
                6|7|8|9|10)
                    swaymsg "workspace $workspace; move workspace to output \"$INTERNAL\"" >/dev/null
                    ;;
            esac
        done
}

case "$MODE" in
    asus)
        swaymsg output "$EXTERNAL" enable >/dev/null
        move_all_to "$EXTERNAL"
        swaymsg output "$INTERNAL" disable >/dev/null
        swaymsg focus output "$EXTERNAL" >/dev/null
        notify_mode "ASUS only"
        ;;

    thinkpad)
        swaymsg output "$INTERNAL" enable >/dev/null
        move_all_to "$INTERNAL"
        swaymsg output "$EXTERNAL" disable >/dev/null
        swaymsg focus output "$INTERNAL" >/dev/null
        notify_mode "ThinkPad only"
        ;;

    dual)
        swaymsg output "$EXTERNAL" enable >/dev/null
        swaymsg output "$INTERNAL" enable >/dev/null
        restore_dual_layout
        swaymsg focus output "$EXTERNAL" >/dev/null
        swaymsg workspace 1 >/dev/null
        notify_mode "Dual screen"
        ;;

    *)
        printf 'Usage: %s {asus|thinkpad|dual}\n' "$0" >&2
        exit 1
        ;;
esac
