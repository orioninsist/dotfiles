#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PATHS_FILE="$ROOT/install/recovery/private-paths.txt"
RECIPIENT_FILE="$ROOT/install/recovery/recipient.txt"

OUTPUT="${1:-$HOME/.config/orion-recovery/private-backup.tar.age}"
TMP="${OUTPUT}.tmp"

umask 077

command -v tar >/dev/null
command -v age >/dev/null

[[ -f "$PATHS_FILE" ]] || {
    echo "ERROR: Missing $PATHS_FILE" >&2
    exit 1
}

[[ -f "$RECIPIENT_FILE" ]] || {
    echo "ERROR: Missing $RECIPIENT_FILE" >&2
    exit 1
}

mkdir -p "$(dirname "$OUTPUT")"
rm -f "$TMP"

paths=()

while IFS= read -r path || [[ -n "$path" ]]; do
    [[ -z "$path" || "$path" == \#* ]] && continue

    if [[ -e "$HOME/$path" ]]; then
        paths+=("$path")
    else
        echo "WARN: Missing source: ~/$path" >&2
    fi
done < "$PATHS_FILE"

((${#paths[@]} > 0)) || {
    echo "ERROR: No recovery sources found." >&2
    exit 1
}

echo "Creating encrypted recovery archive..."

tar \
    -C "$HOME" \
    --exclude='.gnupg/S.gpg-agent*' \
    --exclude='.gnupg/S.dirmngr' \
    --exclude='.gnupg/S.keyboxd' \
    --exclude='.ssh/control*' \
    -cf - \
    "${paths[@]}" |
    age -R "$RECIPIENT_FILE" -o "$TMP"

[[ -s "$TMP" ]] || {
    rm -f "$TMP"
    echo "ERROR: Encrypted archive was not created." >&2
    exit 1
}

mv -f "$TMP" "$OUTPUT"
chmod 600 "$OUTPUT"

echo "OK: $OUTPUT"
stat -c '%a %s bytes %n' "$OUTPUT"
