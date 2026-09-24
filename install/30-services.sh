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
  cliphist.service
  swaybg.service
  easyeffects.service
  orion-audio-state.service
  orion-power-profile-state.service
  espanso.service
  openwith-normalizer.path
  plasma-polkit-agent.service
  gnome-keyring-daemon.socket
)

knowledge_units=(
  knowledge-personal-search.service
  knowledge-personal-watch.service
  knowledge-personal-web.service
)

unit_execs_available() {
  local unit="$1" text path
  text="$(systemctl --user cat "$unit" 2>/dev/null)" || return 1

  while IFS= read -r path; do
    path="${path#-}"
    path="${path//%h/$HOME}"
    [[ "$path" == /* ]] || continue
    if [[ ! -x "$path" ]]; then
      echo "INFO skipping $unit; executable unavailable: $path" >&2
      return 1
    fi
  done < <(printf '%s\n' "$text" | sed -nE 's/^[[:space:]]*ExecStart=[-]?([^[:space:];]+).*/\1/p')

  return 0
}

missing_required=()
for unit in "${required_units[@]}"; do
  if systemctl --user cat "$unit" >/dev/null 2>&1; then
    systemctl --user enable "$unit"
  else
    missing_required+=("$unit")
  fi
done

for unit in "${optional_units[@]}"; do
  if ! systemctl --user cat "$unit" >/dev/null 2>&1; then
    echo "INFO optional unit unavailable: $unit" >&2
    continue
  fi

  if unit_execs_available "$unit"; then
    systemctl --user enable "$unit" || true
  else
    systemctl --user disable "$unit" >/dev/null 2>&1 || true
  fi
done

# chrome-webapps-sync.path has no matching service in the repository, so never enable it blindly.
systemctl --user disable chrome-webapps-sync.path >/dev/null 2>&1 || true

knowledge_root="/mnt/local/projects/knowledge"
if [[ -d "$knowledge_root" ]]; then
  echo "Knowledge project detected: $knowledge_root"
  for unit in "${knowledge_units[@]}"; do
    if systemctl --user cat "$unit" >/dev/null 2>&1 && unit_execs_available "$unit"; then
      systemctl --user enable "$unit"
    else
      echo "INFO Knowledge unit unavailable or dependency missing: $unit" >&2
    fi
  done
else
  echo "INFO Knowledge project absent; Knowledge services remain disabled."
  for unit in "${knowledge_units[@]}"; do
    systemctl --user disable "$unit" >/dev/null 2>&1 || true
  done
fi

if (("${#missing_required[@]}" > 0)); then
  printf 'Missing required user unit: %s\n' "${missing_required[@]}" >&2
  exit 1
fi
