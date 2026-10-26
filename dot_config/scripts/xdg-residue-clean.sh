#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat <<'HELP'
Kullanım: xdg-residue-clean.sh [--help]

Amaç:
  XDG dizinlerinin doğrudan altındaki boş klasörleri temizler.

Kapsam:
  $XDG_CONFIG_HOME (varsayılan ~/.config)
  $XDG_DATA_HOME   (varsayılan ~/.local/share)
  $XDG_STATE_HOME  (varsayılan ~/.local/state)

Güvenlik:
  - Yalnızca boş dizinleri rmdir ile kaldırır.
  - Dosyaları ve dolu dizinleri silmez.
  - Alt dizinlerde özyinelemeli temizlik yapmaz.
  - Symlink takip etmez.
  - sudo gerektirmez.
  - SELinux bağlamlarını değiştirmez.

Seçenekler:
  -h, --help    Bu yardımı göster.
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
    printf 'Hata: Bilinmeyen seçenek: %s\n' "$1" >&2
    usage >&2
    exit 2
    ;;
esac

if (( $# > 1 )); then
  printf 'Hata: Fazla argüman.\n' >&2
  exit 2
fi

removed=0

for base in \
  "${XDG_CONFIG_HOME:-$HOME/.config}" \
  "${XDG_DATA_HOME:-$HOME/.local/share}" \
  "${XDG_STATE_HOME:-$HOME/.local/state}"
do
  [[ -d "$base" && ! -L "$base" ]] || continue

  while IFS= read -r -d '' dir; do
    if rmdir -- "$dir" 2>/dev/null; then
      printf 'TEMİZLENDİ: %s\n' "$dir"
      ((removed+=1))
    fi
  done < <(
    find "$base" -mindepth 1 -maxdepth 1 -type d -empty -print0
  )
done

printf 'Temizlenen boş dizin: %d\n' "$removed"
