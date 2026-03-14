#!/usr/bin/env bash

CARD="alsa_card.pci-0000_00_1f.3"

get_default_sink() {
    pactl info | awk -F': ' '/Default Sink/ {print $2}'
}

get_sink_by_pattern() {
    local pattern="$1"
    pactl list sinks short | awk '{print $2}' | grep -m1 "$pattern"
}

move_all_inputs() {
    local target="$1"
    [ -z "$target" ] && exit 1
    pactl set-default-sink "$target"
    for input in $(pactl list short sink-inputs | awk '{print $1}'); do
        pactl move-sink-input "$input" "$target"
    done
}

CURRENT="$(get_default_sink)"

if echo "$CURRENT" | grep -q '\.hdmi-'; then
    pactl set-card-profile "$CARD" output:analog-stereo
    sleep 1
    TARGET="$(get_sink_by_pattern '\.analog-stereo$')"
    move_all_inputs "$TARGET"
else
    pactl set-card-profile "$CARD" output:hdmi-stereo
    sleep 1
    TARGET="$(get_sink_by_pattern '\.hdmi-stereo$')"
    move_all_inputs "$TARGET"
fi
