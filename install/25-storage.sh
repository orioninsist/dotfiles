#!/usr/bin/env bash
set -Eeuo pipefail

SSD_UUID="e2aafb35-8be2-4d13-87a3-f4b644748d59"
BACKING_MOUNT="/mnt/.data"
PROJECTS_MOUNT="/mnt/projects"
PROJECTS_SOURCE="$BACKING_MOUNT/local/projects"

FSTAB_BEGIN="# BEGIN dotfiles projects storage"
FSTAB_END="# END dotfiles projects storage"

if ! command -v findmnt >/dev/null 2>&1 ||
   ! command -v blkid >/dev/null 2>&1; then
    echo "INFO storage tools unavailable; skipping projects storage."
    exit 0
fi

device="$(blkid -U "$SSD_UUID" 2>/dev/null || true)"
if [[ -z "$device" ]]; then
    echo "INFO projects SSD UUID $SSD_UUID not present; skipping storage setup."
    exit 0
fi

echo "Projects SSD detected: $device"

sudo mkdir -p "$BACKING_MOUNT" "$PROJECTS_MOUNT"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

sudo awk -v begin="$FSTAB_BEGIN" -v end="$FSTAB_END" '
    $0 == begin { skip=1; next }
    $0 == end   { skip=0; next }
    !skip       { print }
' /etc/fstab > "$tmp"

cat >> "$tmp" <<EOF_FSTAB

$FSTAB_BEGIN
UUID=$SSD_UUID $BACKING_MOUNT ext4 defaults,nofail 0 2
$PROJECTS_SOURCE $PROJECTS_MOUNT none bind,x-systemd.requires-mounts-for=$BACKING_MOUNT 0 0
$FSTAB_END
EOF_FSTAB

sudo install -m 0644 "$tmp" /etc/fstab
sudo systemctl daemon-reload

if ! findmnt -rn -M "$BACKING_MOUNT" >/dev/null; then
    sudo mount "$BACKING_MOUNT"
fi

backing_source="$(findmnt -rn -M "$BACKING_MOUNT" -o SOURCE)"
[[ "$backing_source" == "$device" ]] || {
    echo "Unexpected source mounted at $BACKING_MOUNT: $backing_source" >&2
    exit 1
}

if [[ ! -d "$PROJECTS_SOURCE" ]]; then
    echo "Expected projects directory missing: $PROJECTS_SOURCE" >&2
    exit 1
fi

if ! findmnt -rn -M "$PROJECTS_MOUNT" >/dev/null; then
    sudo mount "$PROJECTS_MOUNT"
fi

projects_source="$(findmnt -rn -M "$PROJECTS_MOUNT" -o SOURCE)"
[[ "$projects_source" == "$device[/local/projects]" ]] || {
    echo "Unexpected source mounted at $PROJECTS_MOUNT: $projects_source" >&2
    exit 1
}

echo "Projects storage ready: $PROJECTS_MOUNT"
