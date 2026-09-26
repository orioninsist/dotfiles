#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

RECOVERY_DIR="${ORION_RECOVERY_DIR:-$HOME/.config/orion-recovery}"
BACKUP="${ORION_RECOVERY_BACKUP:-$RECOVERY_DIR/private-backup.tar.age}"
IDENTITY="${ORION_RECOVERY_IDENTITY:-$RECOVERY_DIR/identity.txt}"
RESTORE="$ROOT/install/recovery/restore-private.sh"

echo "Checking private recovery material..."

if [[ ! -f "$BACKUP" ]]; then
    echo "INFO No encrypted recovery backup found."
    echo "INFO Expected: $BACKUP"
    echo "INFO Private recovery restore skipped."
    exit 0
fi

if [[ ! -f "$IDENTITY" ]]; then
    echo "INFO Encrypted recovery backup exists, but age identity is unavailable."
    echo "INFO Expected: $IDENTITY"
    echo "INFO Private recovery restore skipped."
    exit 0
fi

[[ -x "$RESTORE" ]] || {
    echo "ERROR: Recovery restore script missing or not executable: $RESTORE" >&2
    exit 1
}

echo "Encrypted recovery material found."
"$RESTORE" "$BACKUP" "$IDENTITY" "$HOME"

echo "Private recovery restore complete."
