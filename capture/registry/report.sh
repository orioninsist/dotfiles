#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
HOME_DIR="${HOME}"

STATE_DIR="$ROOT_DIR/state/registry"

WATCH_LIST="$STATE_DIR/watch.list"
BLOCK_LIST="$STATE_DIR/block.list"
CAPTURE_FILES="$STATE_DIR/capture.files"
UNCLASSIFIED="$STATE_DIR/unclassified.list"

"$ROOT_DIR/capture/registry/apply.sh" >/dev/null

: > "$UNCLASSIFIED"

is_prefix_match() {
  local path="$1"
  local prefix="$2"

  [ "$path" = "$prefix" ] && return 0
  case "$path" in
    "$prefix"/*) return 0 ;;
  esac

  return 1
}

is_listed_or_child_of_listed() {
  local path="$1"
  local list="$2"
  local item

  [ -f "$list" ] || return 1

  while IFS= read -r item || [ -n "$item" ]; do
    [ -z "$item" ] && continue
    is_prefix_match "$path" "$item" && return 0
  done < "$list"

  return 1
}

while IFS= read -r watch_path || [ -n "$watch_path" ]; do
  [ -z "$watch_path" ] && continue

  abs_path="$HOME_DIR/$watch_path"

  if [ "$watch_path" = "." ]; then
    abs_path="$HOME_DIR"
  fi

  [ -e "$abs_path" ] || continue

  find "$abs_path" -mindepth 1 -maxdepth 1 -printf '%P\n' | while IFS= read -r child; do
    [ -z "$child" ] && continue

    if [ "$watch_path" = "." ]; then
      rel="$child"
    else
      rel="$watch_path/$child"
    fi

    if is_listed_or_child_of_listed "$rel" "$BLOCK_LIST"; then
      continue
    fi

    if is_listed_or_child_of_listed "$rel" "$CAPTURE_FILES"; then
      continue
    fi

    if is_listed_or_child_of_listed "$rel" "$WATCH_LIST"; then
      continue
    fi

    printf '%s\n' "$rel" >> "$UNCLASSIFIED"
  done
done < "$WATCH_LIST"

sort -u -o "$UNCLASSIFIED" "$UNCLASSIFIED"

echo "unclassified paths:"
if [ -s "$UNCLASSIFIED" ]; then
  cat "$UNCLASSIFIED"
else
  echo "(none)"
fi
