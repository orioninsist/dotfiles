#!/usr/bin/env bash
set -Eeuo pipefail

systemctl --user daemon-reload

required_units=(
  ssh-agent.service
  swayidle.service
  niri-keyboard-state.service
  zellij-copy.path
)

optional_units=(
  easyeffects.service
  orion-audio-state.service
  orion-power-profile-state.service
  espanso.service
  openwith-normalizer.path
)

missing_required=()
for unit in "${required_units[@]}"; do
  if systemctl --user cat "$unit" >/dev/null 2>&1; then
    systemctl --user enable "$unit"
  else
    missing_required+=("$unit")
  fi
done

for unit in "${optional_units[@]}"; do
  if systemctl --user cat "$unit" >/dev/null 2>&1; then
    systemctl --user enable "$unit" || true
  else
    echo "INFO optional unit unavailable: $unit" >&2
  fi
done

if (("${#missing_required[@]}" > 0)); then
  printf 'Missing required user unit: %s
' "${missing_required[@]}" >&2
  exit 1
fi
