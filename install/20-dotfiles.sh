#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="${DOTFILES_ROOT:?}"

mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/.local/share"

link_one() {
  local src="$1" dst="$2"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    echo "REFUSE: $dst exists and is not a symlink" >&2
    return 1
  fi
  ln -sfn "$src" "$dst"
}

for p in "$ROOT"/.config/*; do
  [[ -e "$p" ]] || continue
  link_one "$p" "$HOME/.config/${p##*/}"
done

for p in "$ROOT"/.local/bin/*; do
  [[ -f "$p" ]] || continue
  chmod +x "$p"
  link_one "$p" "$HOME/.local/bin/${p##*/}"
done

for f in .bashrc .bash_profile .profile; do
  [[ -e "$ROOT/$f" ]] || continue
  link_one "$ROOT/$f" "$HOME/$f"
done
