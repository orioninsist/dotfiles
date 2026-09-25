#!/usr/bin/env bash
set -u

echo "===== OS ====="
cat /etc/os-release
uname -a

echo
echo "===== VIRTUALIZATION ====="
systemd-detect-virt || true
systemd-detect-virt --vm || true

echo
echo "===== DNF REPOS ====="
dnf repolist --enabled || true

echo
echo "===== REQUIRED COMMANDS ====="
for cmd in bash dnf git niri foot kitty nvim swayimg mpv mako makoctl wl-copy wl-paste grim slurp tesseract ffmpeg ffprobe playerctl brightnessctl swayidle swaylock swaybg notify-send wpctl pactl busctl systemctl fzf rg jq; do
  if command -v "$cmd" >/dev/null 2>&1; then
    printf 'OK\t%s\t%s\n' "$cmd" "$(command -v "$cmd")"
  else
    printf 'MISSING\t%s\n' "$cmd"
  fi
done

echo
echo "===== INSTALLED RPM OWNERS ====="
for bin in "$(command -v niri 2>/dev/null)" "$(command -v foot 2>/dev/null)" "$(command -v mako 2>/dev/null)" "$(command -v makoctl 2>/dev/null)" "$(command -v tesseract 2>/dev/null)" "$(command -v ffmpeg 2>/dev/null)"; do
  [[ -n "$bin" ]] || continue
  rpm -qf "$bin" || true
done

echo
echo "===== USER UNITS ====="
systemctl --user list-unit-files --state=enabled --no-pager || true

echo
echo "===== SYSTEM UNITS ====="
systemctl list-unit-files --state=enabled --no-pager || true

echo
echo "===== QEMU GUEST AGENT ====="
systemctl status qemu-guest-agent.service --no-pager -l || true

echo
echo "===== FAILED UNITS ====="
systemctl --failed --no-pager || true
systemctl --user --failed --no-pager || true

echo
echo "===== NIRI CONFIG CHECK ====="
niri validate 2>&1 || true

echo
echo "===== ABSOLUTE LEGACY PATHS ====="
grep -RniE '/usr/local/bin' "$HOME/.config" "$HOME/.local" "$HOME/.bashrc" "$HOME/.profile" 2>/dev/null || true
