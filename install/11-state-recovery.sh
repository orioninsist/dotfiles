#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${DOTFILES_ROOT:?}"
RPM_STATE="$ROOT/state/packages/rpm.txt"
FLATPAK_STATE="$ROOT/state/packages/flatpak.txt"

if [[ -s "$RPM_STATE" ]] && grep -qEv '^[[:space:]#]*$' "$RPM_STATE"; then
  mapfile -t packages < <(grep -Ev '^[[:space:]#]*$' "$RPM_STATE" | sort -u)
  missing=()
  for package in "${packages[@]}"; do
    rpm -q "$package" >/dev/null 2>&1 || missing+=("$package")
  done
  if ((${#missing[@]})); then
    echo "Installing ${#missing[@]} packages from recorded system state..."
    sudo dnf -y install "${missing[@]}"
  else
    echo "Recorded RPM package state is already satisfied."
  fi
else
  echo "No generated RPM state found; using the baseline manifest only."
fi

if command -v flatpak >/dev/null 2>&1 && [[ -s "$FLATPAK_STATE" ]] && grep -qEv '^[[:space:]#]*$' "$FLATPAK_STATE"; then
  while IFS= read -r app; do
    [[ -z "$app" || "$app" == \#* ]] && continue
    flatpak info "$app" >/dev/null 2>&1 || flatpak install -y flathub "$app"
  done < "$FLATPAK_STATE"
else
  echo "No generated Flatpak state found; skipping Flatpak recovery."
fi
