#!/usr/bin/env bash
set -u

repo="${1:-$PWD}"
echo "===== HOST ====="
cat /etc/os-release
uname -a

echo
echo "===== REFERENCED COMMANDS / ABSOLUTE PATHS ====="
grep -RhoE '(/usr/(local/)?bin/[A-Za-z0-9._+-]+|/home/[A-Za-z0-9._-]+/[^"[:space:];]+|/mnt/local/[^"[:space:];]+)'   "$repo/.config" "$repo/.local" "$repo/.bashrc" "$repo/.profile" "$repo/.bash_profile" 2>/dev/null |
  sort -u

echo
echo "===== PACMAN OWNER FOR REFERENCED /usr BINARIES ====="
while read -r bin; do
  [[ -e "$bin" ]] || { printf 'MISSING\t%s\n' "$bin"; continue; }
  owner="$(pacman -Qo "$bin" 2>/dev/null || true)"
  printf '%s\t%s\n' "$bin" "${owner:-UNOWNED}"
done < <(
  grep -RhoE '/usr/(local/)?bin/[A-Za-z0-9._+-]+'     "$repo/.config" "$repo/.local" "$repo/.bashrc" "$repo/.profile" "$repo/.bash_profile" 2>/dev/null |
  sort -u
)

echo
echo "===== EXPLICIT PACMAN PACKAGES ====="
pacman -Qqe 2>/dev/null || true

echo
echo "===== FOREIGN/AUR PACKAGES ====="
pacman -Qqm 2>/dev/null || true

echo
echo "===== ENABLED SYSTEM SERVICES ====="
systemctl list-unit-files --state=enabled --no-pager 2>/dev/null || true

echo
echo "===== ENABLED USER SERVICES/PATHS ====="
systemctl --user list-unit-files --state=enabled --no-pager 2>/dev/null || true

echo
echo "===== FAILED ====="
systemctl --failed --no-pager 2>/dev/null || true
systemctl --user --failed --no-pager 2>/dev/null || true
