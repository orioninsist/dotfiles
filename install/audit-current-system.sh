#!/usr/bin/env bash
set -u

repo="${1:-$PWD}"

scan_roots=(
  "$repo/.config"
  "$repo/.local"
  "$repo/.bashrc"
  "$repo/.profile"
  "$repo/.bash_profile"
)

echo "===== HOST ====="
cat /etc/os-release
uname -a

echo
echo "===== REFERENCED COMMANDS / ABSOLUTE PATHS ====="
grep -RhoE   --exclude='emoji-test.txt'   --exclude='*.wasm'   --exclude='*.lock'   --exclude-dir='.git'   --exclude-dir='target'   --exclude-dir='node_modules'   --exclude-dir='.venv'   --exclude-dir='__pycache__'   '(/usr/(local/)?bin/[A-Za-z0-9._+-]+|/home/[A-Za-z0-9._-]+/[^"[:space:];]+|/mnt/local/[^"[:space:];]+)'   "${scan_roots[@]}" 2>/dev/null |
  sort -u

echo
echo "===== PACMAN OWNER FOR REFERENCED /usr BINARIES ====="
while read -r bin; do
  [[ -n "$bin" ]] || continue
  [[ -e "$bin" ]] || { printf 'MISSING\t%s\n' "$bin"; continue; }
  owner="$(pacman -Qo "$bin" 2>/dev/null || true)"
  printf '%s\t%s\n' "$bin" "${owner:-UNOWNED}"
done < <(
  grep -RhoE     --exclude='emoji-test.txt'     --exclude='*.wasm'     --exclude='*.lock'     --exclude-dir='.git'     --exclude-dir='target'     --exclude-dir='node_modules'     --exclude-dir='.venv'     --exclude-dir='__pycache__'     '/usr/(local/)?bin/[A-Za-z0-9._+-]+'     "${scan_roots[@]}" 2>/dev/null |
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
