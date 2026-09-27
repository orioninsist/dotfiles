#!/usr/bin/env bash
set -Eeuo pipefail

MEDIA="${HOME:?}/Media"
REMOTE="gdrive:Media"
RULES="${HOME:?}/dotfiles/install/rclone/media-cloud-only.rules"

[[ -d "$MEDIA" ]] || {
    echo "FAIL Media directory missing: $MEDIA" >&2
    exit 1
}

[[ -f "$RULES" ]] || {
    echo "FAIL cloud-only rules missing: $RULES" >&2
    exit 1
}

command -v rclone >/dev/null 2>&1 || {
    echo "FAIL rclone is not installed" >&2
    exit 1
}

run_move() {
    rclone move \
        "$MEDIA" \
        "$REMOTE" \
        --filter-from "$RULES" \
        --links \
        --progress \
        --stats 10s \
        --stats-one-line \
        --human-readable \
        "$@"
}

case "${1:-dry-run}" in
    dry-run)
        echo "===== CLOUD-ONLY MOVE — DRY RUN ====="
        run_move --dry-run
        ;;
    move)
        echo "===== CLOUD-ONLY MOVE ====="
        run_move
        ;;
    *)
        echo "Usage: $0 {dry-run|move}" >&2
        exit 2
        ;;
esac
