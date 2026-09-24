#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${DOTFILES_ROOT:?}"
BIN_DIR="$HOME/.local/bin"

mkdir -p "$BIN_DIR"

echo "==> Enabling required COPR repositories"

enable_copr() {
  local repo=$1

  if dnf -q repolist --enabled 2>/dev/null |
       awk '{print $1}' |
       grep -Fqx "copr:copr.fedorainfracloud.org:${repo/\//:}"; then
    echo "COPR already enabled: $repo"
    return 0
  fi

  sudo dnf -y copr enable "$repo"
}

enable_copr "lihaohong/yazi"
enable_copr "frodo/zellij"

echo
echo "==> Installing COPR packages"

missing=()
for pkg in yazi zellij; do
  rpm -q "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
done

if ((${#missing[@]})); then
  sudo dnf -y install "${missing[@]}"
else
  echo "Yazi and Zellij already installed."
fi

echo
echo "==> Installing wl-screenrec"

if command -v wl-screenrec >/dev/null 2>&1; then
  echo "wl-screenrec already available: $(command -v wl-screenrec)"
else
  cargo install --locked wl-screenrec
fi

echo
echo "==> Installing wl-color-picker"

if command -v wl-color-picker >/dev/null 2>&1; then
  echo "wl-color-picker already available: $(command -v wl-color-picker)"
else
  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' EXIT

  curl -fL \
    https://raw.githubusercontent.com/jgmdev/wl-color-picker/main/wl-color-picker.sh \
    -o "$tmp"

  install -m 0755 "$tmp" "$BIN_DIR/wl-color-picker"
  rm -f "$tmp"
  trap - EXIT
fi

echo
echo "==> Building Zellij plugins"

build_zellij_plugin() {
  local name=$1
  local wasm=$2
  local plugin_dir="$ROOT/.config/zellij/plugins/$name"
  local built="$plugin_dir/target/wasm32-wasip1/release/$wasm"
  local dist="$plugin_dir/dist/$wasm"

  echo "Building: $name"

  cargo build \
    --manifest-path "$plugin_dir/Cargo.toml" \
    --locked \
    --release \
    --target wasm32-wasip1

  test -f "$built" || {
    echo "Expected WASM not produced: $built" >&2
    return 1
  }

  mkdir -p "$plugin_dir/dist"
  install -m 0644 "$built" "$dist"
}

build_zellij_plugin "orion-status" "orion-status.wasm"
build_zellij_plugin "scrollback-copy" "zellij-scrollback-copy.wasm"

echo
echo "==> Verifying external tools"

failed=0

for cmd in yazi zellij wl-screenrec wl-color-picker; do
  if command -v "$cmd" >/dev/null 2>&1; then
    printf 'OK   %-20s %s\n' "$cmd" "$(command -v "$cmd")"
  else
    printf 'FAIL %-20s missing\n' "$cmd" >&2
    failed=1
  fi
done

((failed == 0))
