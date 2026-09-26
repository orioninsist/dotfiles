#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_ROOT="$ROOT"

START_SECONDS=$SECONDS
CURRENT_PHASE="startup"
CURRENT_INDEX=0
TOTAL_PHASES=15
declare -a PHASE_RESULTS=()

elapsed() {
  local seconds=$1
  printf '%dm %02ds' "$((seconds / 60))" "$((seconds % 60))"
}

on_error() {
  local rc=$?
  local line=$1
  local command=$2
  echo
  echo "FAIL [$CURRENT_INDEX/$TOTAL_PHASES] $CURRENT_PHASE"
  echo "Exit code: $rc"
  echo "Line: $line"
  echo "Command: $command"
  echo "Elapsed: $(elapsed "$((SECONDS - START_SECONDS))")"
  exit "$rc"
}
trap 'on_error "$LINENO" "$BASH_COMMAND"' ERR

run_phase() {
  local index=$1
  local name=$2
  local script=$3
  local phase_start=$SECONDS

  CURRENT_INDEX=$index
  CURRENT_PHASE=$name

  echo
  echo "[$index/$TOTAL_PHASES] $name"
  echo "Script: ${script#"$ROOT/"}"

  bash "$script"

  local duration=$((SECONDS - phase_start))
  PHASE_RESULTS+=("OK [$index/$TOTAL_PHASES] $name - $(elapsed "$duration")")
  echo "OK [$index/$TOTAL_PHASES] $(elapsed "$duration")"
}

echo "== Fedora dotfiles installer =="
echo "Repo: $ROOT"
echo "Started: $(date '+%Y-%m-%d %H:%M:%S')"

echo
echo "Checking sudo credentials..."
sudo -v
echo "OK sudo credentials"

run_phase 1 "Preflight checks" "$ROOT/install/05-preflight.sh"
run_phase 2 "Fedora packages" "$ROOT/install/10-base.sh"
run_phase 3 "Recorded system state" "$ROOT/install/11-state-recovery.sh"
run_phase 4 "External tools" "$ROOT/install/12-external-tools.sh"
run_phase 5 "Vendor applications" "$ROOT/install/13-vendor-apps.sh"
run_phase 6 "Google Sans Code font" "$ROOT/install/15-fonts.sh"
run_phase 7 "Dotfiles installation" "$ROOT/install/20-dotfiles.sh"
run_phase 8 "Private recovery" "$ROOT/install/22-recovery.sh"
run_phase 9 "Persistent projects storage" "$ROOT/install/25-storage.sh"
run_phase 10 "Whisper voice typing" "$ROOT/install/27-whisper.sh"
run_phase 11 "User services" "$ROOT/install/30-services.sh"
run_phase 12 "System services" "$ROOT/install/32-system-services.sh"
run_phase 13 "QEMU guest integration" "$ROOT/install/35-fedora-qemu-guest.sh"
run_phase 14 "Ly, Niri session and SELinux" "$ROOT/install/36-display-manager.sh"
run_phase 15 "Acceptance tests" "$ROOT/install/40-verify.sh"

echo
echo "===== INSTALL SUMMARY ====="
printf '%s\n' "${PHASE_RESULTS[@]}"
echo "Total: $(elapsed "$((SECONDS - START_SECONDS))")"
echo
echo "INSTALL COMPLETE"
echo "Reboot recommended."
