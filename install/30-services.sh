#!/usr/bin/env bash
set -Eeuo pipefail

systemctl --user daemon-reload

units=(
  ssh-agent.service
  swayidle.service
  espanso.service
  easyeffects.service
  orion-audio-state.service
  orion-power-profile-state.service
  niri-keyboard-state.service
  openwith-normalizer.path
  zellij-copy.path
)

for unit in "${units[@]}"; do
  if systemctl --user cat "$unit" >/dev/null 2>&1; then
    systemctl --user enable "$unit"
  else
    echo "WARN missing unit: $unit" >&2
  fi
done
