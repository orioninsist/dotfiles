#!/usr/bin/env bash

MEDIA="${HOME:?}/Media"
RULES="${HOME:?}/dotfiles/install/rclone/media-backup.rules"

REMOTE="gdrive:Media"

if [[ ! -d "$MEDIA" ]]; then
    echo "FAIL Media missing: $MEDIA"
    return 1 2>/dev/null || false
fi

if [[ ! -f "$RULES" ]]; then
    echo "FAIL backup rules missing: $RULES"
    return 1 2>/dev/null || false
fi


if ! command -v rclone >/dev/null 2>&1; then
    echo "FAIL rclone is not installed"
    return 1 2>/dev/null || false
fi




case "${1:-dry-run}" in

    dry-run)

        echo "============================================================"
        echo " BACKUP DRY RUN"
        echo "============================================================"

        rclone copy \
            "$MEDIA" \
            "$REMOTE" \
            --filter-from "$RULES" \
            --links \
            --dry-run \
            --progress \
            --stats 10s \
            --stats-one-line \
            --human-readable

        BACKUP_RC=$?

        echo
        echo "============================================================"

        ;;


    copy)

        echo "============================================================"
        echo " MEDIA -> GOOGLE DRIVE COPY"
        echo "============================================================"

        rclone copy \
            "$MEDIA" \
            "$REMOTE" \
            --filter-from "$RULES" \
            --links \
            --progress \
            --stats 10s \
            --stats-one-line \
            --human-readable

        RC=$?

        if [[ "$RC" -ne 0 ]]; then
            echo
            echo "FAIL rclone copy returned: $RC"
            return "$RC" 2>/dev/null || false
        fi

        echo
        echo "PASS Media backup completed"


        ;;


    *)
        echo "Usage:"
        echo "  $0 dry-run"
        echo "  $0 copy"
        return 2 2>/dev/null || false
        ;;

esac
