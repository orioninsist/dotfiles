#!/usr/bin/env bash
set -u

HOME_DIR="$HOME"
SWAY_DIR="$HOME/.config/sway"
OUT="$SWAY_DIR/sway_home_audit.txt"

{
    echo "=== CURRENT SWAY TREE ==="
    find "$SWAY_DIR" -maxdepth 3 \
        -printf '%y | %p -> %l\n' 2>/dev/null | sort

    echo
    echo "=== SWAY RELATED FILE NAMES UNDER HOME ==="
    find "$HOME_DIR" \
        \( -path "$HOME/.cache" -o \
           -path "$HOME/.cache/*" -o \
           -path "$HOME/.local/share/Trash" -o \
           -path "$HOME/.local/share/Trash/*" \) -prune -o \
        -type f \
        \( -iname '*sway*' -o \
           -iname '*screenshot*' -o \
           -iname '*screen-record*' -o \
           -iname '*camera-record*' -o \
           -iname '*wlsunset*' -o \
           -iname '*cliphist*' -o \
           -iname '*mako-toggle*' -o \
           -iname '*wayland*' \) \
        -printf '%TY-%Tm-%Td %TH:%TM:%TS | %p\n' 2>/dev/null |
        sort

    echo
    echo "=== SYMLINKS POINTING INTO SWAY ==="
    find "$HOME_DIR" \
        \( -path "$HOME/.cache" -o -path "$HOME/.cache/*" \) -prune -o \
        -type l -print 2>/dev/null |
    while IFS= read -r link; do
        target="$(readlink -f "$link" 2>/dev/null || true)"
        case "$target" in
            "$SWAY_DIR"/*)
                printf '%s -> %s\n' "$link" "$target"
                ;;
        esac
    done

    echo
    echo "=== REFERENCES TO CURRENT SWAY SCRIPT PATHS ==="
    grep -RniE \
        '\.config/sway|\.local/bin/(sway-|screenshot-|cliphist-fzf|mako-toggle|wlsunset-toggle)' \
        "$HOME/.config" \
        "$HOME/.local/bin" \
        "$HOME/.local/share/applications" \
        "$HOME/.bashrc" \
        "$HOME/.bash_profile" \
        "$HOME/.profile" \
        2>/dev/null || true

    echo
    echo "=== SWAY CONFIG EXEC/BIND/INCLUDE REFERENCES ==="
    grep -RniE \
        '^[[:space:]]*(include|exec|exec_always|bindsym|bindcode|status_command)' \
        "$SWAY_DIR/config" \
        "$SWAY_DIR/session.conf" \
        "$SWAY_DIR/workspaces.conf" \
        2>/dev/null || true

    echo
    echo "=== SCRIPT TO SCRIPT REFERENCES ==="
    find "$SWAY_DIR/scripts" "$HOME/.local/bin" \
        -maxdepth 1 -type f -print0 2>/dev/null |
    while IFS= read -r -d '' file; do
        if head -n1 "$file" 2>/dev/null | grep -qE '^#!.*(bash|sh)'; then
            grep -nE \
                '\.local/bin|\.config/sway|sway-|screenshot-|cliphist|mako|wlsunset|wl-copy|wl-paste' \
                "$file" 2>/dev/null |
                sed "s|^|$file:|" || true
        fi
    done

    echo
    echo "=== SYSTEMD USER REFERENCES ==="
    grep -RniE \
        'sway|swaylock|swayidle|screenshot|screen-record|camera-record|cliphist|mako|wlsunset|\.config/sway|\.local/bin' \
        "$HOME/.config/systemd/user" 2>/dev/null || true

    echo
    echo "=== DESKTOP ENTRY REFERENCES ==="
    grep -RniE \
        'sway|screenshot|cliphist|mako|wlsunset|\.config/sway|\.local/bin' \
        "$HOME/.local/share/applications" 2>/dev/null || true

    echo
    echo "=== EXECUTABLE PERSONAL FILES OUTSIDE SWAY ==="
    find "$HOME" \
        \( -path "$HOME/.cache" -o \
           -path "$HOME/.cache/*" -o \
           -path "$HOME/.config/sway" -o \
           -path "$HOME/.config/sway/*" -o \
           -path "$HOME/.local/share/Trash" -o \
           -path "$HOME/.local/share/Trash/*" \) -prune -o \
        -type f -perm /111 \
        \( -path "$HOME/.local/bin/*" -o -path "$HOME/bin/*" \) \
        -printf '%p\n' 2>/dev/null

    echo
    echo "=== BROKEN PERSONAL SYMLINKS ==="
    find "$HOME/.local/bin" "$SWAY_DIR" -xtype l \
        -printf '%p -> %l\n' 2>/dev/null || true

    echo
    echo "=== RUNNING SWAY RELATED COMMANDS ==="
    ps -eo pid,ppid,args |
        grep -Ei \
        'sway|swaybar|swayidle|swaylock|mako|wlsunset|cliphist|screen-record|camera-record|screenshot' |
        grep -v grep || true

    echo
    echo "=== SWAY VALIDATION ==="
    sway -C -c "$SWAY_DIR/config" 2>&1 || true

} > "$OUT"

printf 'Created: %s\n' "$OUT"
