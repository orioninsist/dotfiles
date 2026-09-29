#!/usr/bin/env bash

APP_DIR="$HOME/.local/share/applications"

printf "%-25s | %s\n" "WEB APP" "APP ID"
printf '%*s\n' 62 '' | tr ' ' '-'

for file in "$APP_DIR"/chrome-*.desktop; do
    [[ -f "$file" ]] || continue

    name=$(sed -n 's/^Name=//p' "$file" | head -n1)
    appid=$(sed -n 's/.*--app-id=\([a-p]\{32\}\).*/\1/p' "$file" | head -n1)

    [[ -n "$name" && -n "$appid" ]] || continue

    printf "%-25s | %s\n" "$name" "$appid"
done
