#!/usr/bin/env bash

HOME_DIR="${HOME:?}"
MEDIA="$HOME_DIR/Media"

DOTFILES_SRC="$HOME_DIR/dotfiles"
DOTFILES_DST="$MEDIA/6-Project/dotfiles"

RECOVERY_SRC="$HOME_DIR/.config/orion-recovery"
RECOVERY_DST="$MEDIA/8-Document/system-recovery"

echo "===== STAGE DOTFILES ====="

mkdir -p "$DOTFILES_DST"

if [[ -d "$DOTFILES_SRC" ]]; then
    rsync -a \
        --delete \
        --exclude='.git/' \
        "$DOTFILES_SRC/" \
        "$DOTFILES_DST/" &&
        echo "PASS dotfiles staged" ||
        echo "FAIL dotfiles staging"
else
    echo "FAIL dotfiles source missing: $DOTFILES_SRC"
fi

echo
echo "===== STAGE ENCRYPTED RECOVERY ====="

mkdir -p "$RECOVERY_DST"
chmod 700 "$RECOVERY_DST"

for file in \
    private-backup.tar.age \
    identity.txt.age
do
    SRC="$RECOVERY_SRC/$file"
    DST="$RECOVERY_DST/$file"

    if [[ -f "$SRC" ]]; then
        install -m 600 "$SRC" "$DST" &&
            echo "PASS $file" ||
            echo "FAIL $file"
    else
        echo "FAIL missing: $SRC"
    fi
done

echo
echo "===== SECURITY CHECK ====="

if [[ -e "$RECOVERY_DST/identity.txt" ]]; then
    echo "FAIL plaintext identity.txt exists in Media!"
    rm -f "$RECOVERY_DST/identity.txt"
    echo "REMOVED plaintext identity.txt"
else
    echo "PASS plaintext identity.txt is NOT staged"
fi
