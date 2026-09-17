#!/usr/bin/env bash
set -euo pipefail

echo "=== CENTRAL SCRIPTS ==="
find "$HOME/.config/sway/scripts" -maxdepth 1 -type f -printf '%f\n' | sort

echo
echo "=== COMPATIBILITY LINKS ==="
find "$HOME/.local/bin" -maxdepth 1 -type l -lname "$HOME/.config/sway/scripts/*" \
    -printf '%f -> %l\n' | sort

echo
echo "=== BROKEN LINKS ==="
broken=0

while IFS= read -r link; do
    if [[ ! -e "$link" ]]; then
        echo "BROKEN: $link -> $(readlink "$link")"
        broken=1
    fi
done < <(
    find "$HOME/.local/bin" -maxdepth 1 -type l \
        -lname "$HOME/.config/sway/scripts/*" -print
)

(( broken == 0 )) && echo "NO BROKEN LINKS"

echo
echo "=== SHELL SYNTAX ==="
for file in "$HOME/.config/sway/scripts/"*; do
    [[ -f "$file" ]] || continue

    if head -n1 "$file" | grep -qE '(bash|/sh)'; then
        bash -n "$file"
        echo "OK: $(basename "$file")"
    fi
done

echo
echo "=== SWAY VALIDATION ==="
sway -C -c "$HOME/.config/sway/config"
