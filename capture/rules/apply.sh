#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

RULES="$ROOT_DIR/capture/rules/default.rules"
INPUT="$ROOT_DIR/state/discovered/files.list"
OUTPUT="$ROOT_DIR/state/approved/files.list"

echo "================================"
echo " RULE ENGINE"
echo "================================"

mkdir -p "$(dirname "$OUTPUT")"

> "$OUTPUT"

while read -r item
do
    [ -z "$item" ] && continue

    allowed=false

    while read -r rule pattern
    do
        [ -z "$rule" ] && continue
        [[ "$rule" == \#* ]] && continue

        [ "$rule" = "ALLOW" ] || continue

        case "$pattern" in
            *"**")
                prefix="${pattern%\*\*}"
                prefix="${prefix%/}"

                if [[ "$item" == "$prefix" || "$item" == "$prefix/"* ]]; then
                    allowed=true
                fi
                ;;

            *)
                if [[ "$item" == "$pattern" ]]; then
                    allowed=true
                fi
                ;;
        esac

    done < "$RULES"


    if [ "$allowed" = true ]; then
        echo "$item" >> "$OUTPUT"
        echo "allowed: $item"
    fi

done < "$INPUT"


echo
echo "approved list:"
echo "$OUTPUT"
