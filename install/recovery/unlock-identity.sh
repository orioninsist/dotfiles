#!/usr/bin/env bash

WRAPPED="${1:-$HOME/.config/orion-recovery/identity.txt.age}"
OUTPUT="${2:-$HOME/.config/orion-recovery/identity.txt}"

umask 077

if [[ ! -f "$WRAPPED" ]]; then
    echo "FAIL encrypted identity missing: $WRAPPED"
    return 1 2>/dev/null || false
else
    mkdir -p "$(dirname "$OUTPUT")"

    TMP="${OUTPUT}.tmp"
    rm -f "$TMP"

    echo "Recovery parolanı gir:"

    if age -d -o "$TMP" "$WRAPPED"; then
        chmod 600 "$TMP"
        mv -f "$TMP" "$OUTPUT"
        echo "PASS recovery identity unlocked: $OUTPUT"
    else
        rm -f "$TMP"
        echo "FAIL recovery identity could not be unlocked"
    fi
fi
