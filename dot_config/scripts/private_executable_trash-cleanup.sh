#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'HELP'
Kullanım:
  trash-cleanup.sh [--help]

Seçenekler:
  -h, --help    Bu yardım mesajını gösterir.

Açıklama:
  XDG çöp kutusunun boyutunu gösterir ve kullanıcı
  onayıyla içeriğini kalıcı olarak temizler.

Gereksinimler:
  Fedora Linux, Bash, trash-cli

Güvenlik:
  - Silme öncesinde kullanıcı onayı ister.
  - sudo kullanmaz.
  - Çöp kutusu dışındaki dosyaları hedeflemez.
  - İzinleri otomatik değiştirmez.
  - Silinen dosyalar geri alınamaz.
HELP
}

case "${1:-}" in
    -h|--help)
        usage
        exit 0
        ;;
    "")
        ;;
    *)
        printf 'Bilinmeyen seçenek: %s\\n' "$1" >&2
        usage >&2
        exit 2
        ;;
esac

if (( $# > 1 )); then
    printf 'Hata: Fazla argüman.\\n' >&2
    exit 2
fi

trash="${XDG_DATA_HOME:-$HOME/.local/share}/Trash"
files="$trash/files"

command -v trash-empty >/dev/null 2>&1 || {
    printf 'Hata: trash-cli kurulu değil.\n' >&2
    exit 1
}

if [[ ! -d "$trash" ]]; then
    printf 'Çöp kutusu bulunamadı.\n'
    exit 0
fi

printf 'Çöp kutusu boyutu: '
du -sh -- "$trash" 2>/dev/null | cut -f1

read -r -p 'Çöp kutusu kalıcı olarak boşaltılsın mı? [y/N] ' answer

[[ "$answer" == [yY] ]] || {
    printf 'İşlem iptal edildi.\n'
    exit 0
}

if ! trash-empty --force; then
    printf 'Temizlik tamamlanamadı. İzinler kontrol edilmeli.\n' >&2
    exit 1
fi

printf '\nKalan çöp kutusu boyutu: '
du -sh -- "$trash" 2>/dev/null | cut -f1
