#!/usr/bin/env bash
set -Eeuo pipefail

BACKUP="${1:-$HOME/.config/orion-recovery/private-backup.tar.age}"
IDENTITY="${2:-$HOME/.config/orion-recovery/identity.txt}"
DESTINATION="${3:-$HOME}"

umask 077

command -v age >/dev/null
command -v tar >/dev/null

[[ -f "$BACKUP" ]] || {
    echo "ERROR: Backup not found: $BACKUP" >&2
    exit 1
}

[[ -f "$IDENTITY" ]] || {
    echo "ERROR: Age identity not found: $IDENTITY" >&2
    exit 1
}

mkdir -p "$DESTINATION"

echo "Restoring encrypted private data..."
echo "Destination: $DESTINATION"

age -d -i "$IDENTITY" "$BACKUP" |
    tar -C "$DESTINATION" \
        --no-same-owner \
        --no-overwrite-dir \
        -xf -

# Enforce critical permissions when restoring to a home-like tree.
[[ -d "$DESTINATION/.ssh" ]] &&
    chmod 700 "$DESTINATION/.ssh"

[[ -d "$DESTINATION/.gnupg" ]] &&
    chmod 700 "$DESTINATION/.gnupg"

[[ -f "$DESTINATION/.config/rclone/rclone.conf" ]] &&
    chmod 600 "$DESTINATION/.config/rclone/rclone.conf"

find "$DESTINATION/.ssh" -type f -name 'id_*' \
    ! -name '*.pub' -exec chmod 600 {} + 2>/dev/null || true

echo "RESTORE COMPLETE"
