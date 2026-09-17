#!/usr/bin/env bash

notification_state="$HOME/.cache/mako-popup-state"
camera_state="$HOME/.cache/camera-state"

notification="󰂚"
camera="󰖠"

if [[ -f "$notification_state" ]] && [[ "$(cat "$notification_state")" == "disabled" ]]; then
    notification="󰂛"
fi

if [[ -f "$camera_state" ]] && [[ "$(cat "$camera_state")" == "off" ]]; then
    camera="󰗟"
fi

printf '%s  %s\n' \
    "$notification" \
    "$camera"
