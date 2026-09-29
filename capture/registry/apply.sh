#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RULES_FILE="$ROOT_DIR/capture/registry/paths.rules"
STATE_DIR="$ROOT_DIR/state/registry"

WATCH_LIST="$STATE_DIR/watch.list"
BLOCK_LIST="$STATE_DIR/block.list"
CAPTURE_FILES="$STATE_DIR/capture.files"

mkdir -p "$STATE_DIR"

: > "$WATCH_LIST"
: > "$BLOCK_LIST"
: > "$CAPTURE_FILES"

current_partial=""

while IFS= read -r line || [ -n "$line" ]; do
  # trim leading/trailing whitespace
  line="$(printf '%s' "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"

  # skip blanks and comments
  [ -z "$line" ] && continue
  case "$line" in
    \#*) continue ;;
  esac

  set -- $line
  action="${1:-}"
  path="${2:-}"

  case "$action" in
    WATCH)
      printf '%s\n' "$path" >> "$WATCH_LIST"
      ;;

    BLOCK)
      printf '%s\n' "$path" >> "$BLOCK_LIST"
      ;;

    TAKE_FILE|TAKE_DIR)
      printf '%s\n' "$path" >> "$CAPTURE_FILES"
      ;;

    TAKE_PARTIAL)
      current_partial="$path"
      ;;

    INCLUDE)
      if [ -z "$current_partial" ]; then
        echo "ERROR: INCLUDE used outside TAKE_PARTIAL" >&2
        exit 1
      fi
      printf '%s/%s\n' "$current_partial" "$path" >> "$CAPTURE_FILES"
      ;;

    END)
      current_partial=""
      ;;

    *)
      echo "ERROR: unknown action: $action" >&2
      exit 1
      ;;
  esac
done < "$RULES_FILE"

sort -u -o "$WATCH_LIST" "$WATCH_LIST"
sort -u -o "$BLOCK_LIST" "$BLOCK_LIST"
sort -u -o "$CAPTURE_FILES" "$CAPTURE_FILES"

echo "registry applied"
echo
echo "watch:"
cat "$WATCH_LIST"
echo
echo "block:"
cat "$BLOCK_LIST"
echo
echo "capture:"
cat "$CAPTURE_FILES"
