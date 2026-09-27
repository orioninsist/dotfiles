#!/usr/bin/env bash

MEDIA="${HOME:?}/Media"
RULES="${HOME:?}/dotfiles/install/rclone/media-backup.rules"
CLOUD_RULES="${HOME:?}/dotfiles/install/rclone/media-cloud-only.rules"

REMOTE="gdrive:Media"

if [[ ! -d "$MEDIA" ]]; then
    echo "FAIL Media missing: $MEDIA"
    return 1 2>/dev/null || false
fi

if [[ ! -f "$RULES" ]]; then
    echo "FAIL backup rules missing: $RULES"
    return 1 2>/dev/null || false
fi

if [[ ! -f "$CLOUD_RULES" ]]; then
    echo "FAIL cloud-only rules missing: $CLOUD_RULES"
    return 1 2>/dev/null || false
fi

if ! command -v rclone >/dev/null 2>&1; then
    echo "FAIL rclone is not installed"
    return 1 2>/dev/null || false
fi


cloud_patterns() {
    sed \
        -e 's/[[:space:]]*$//' \
        -e '/^[[:space:]]*#/d' \
        -e '/^[[:space:]]*$/d' \
        "$CLOUD_RULES"
}


cloud_rule_count() {
    cloud_patterns | wc -l
}


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
        echo " CLOUD-ONLY DRY RUN"
        echo "============================================================"

        COUNT="$(cloud_rule_count)"

        if [[ "$COUNT" -eq 0 ]]; then
            echo "PASS no active cloud-only rules"
            echo "PASS no local files would be removed"
        else
            echo "ACTIVE cloud-only rules:"
            cloud_patterns

            echo
            echo "SAFETY:"
            echo "Cleanup is NOT implemented/enabled yet."
            echo "This run will NOT delete local files."
        fi

        return "$BACKUP_RC" 2>/dev/null || true
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
            echo "FAIL cloud-only cleanup MUST NOT run"
            return "$RC" 2>/dev/null || false
        fi

        echo
        echo "PASS Media backup completed"

        COUNT="$(cloud_rule_count)"

        if [[ "$COUNT" -eq 0 ]]; then
            echo "PASS no active cloud-only rules"
            echo "PASS no local cleanup required"
        else
            echo
            echo "INFO cloud-only rules exist:"
            cloud_patterns
            echo
            echo "SAFETY STOP:"
            echo "Automatic local cleanup is not enabled yet."
        fi
        ;;


    *)
        echo "Usage:"
        echo "  $0 dry-run"
        echo "  $0 copy"
        return 2 2>/dev/null || false
        ;;

esac
