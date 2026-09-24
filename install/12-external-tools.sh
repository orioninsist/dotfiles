#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${DOTFILES_ROOT:?}"
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"
BUN_VERSION="1.3.3"
TYPST_VERSION="0.15.0"
SATTY_VERSION="0.22.0"
CATPPUCCIN_GTK_VERSION="1.0.3"
CATPPUCCIN_GTK_THEME="catppuccin-mocha-mauve-standard+default"
CATPPUCCIN_GTK_SHA256="cbacdac6161f98c315fb86740e21426ef6dda64f0ad69157cf28f3a1dda446fe"
SATTY_SHA256="eb7a028c4a5ce331c2f355add8e2b807a7d697fe4495f7e1965786a4f6bcd5b8"

mkdir -p "$BIN_DIR"
export PATH="$BIN_DIR:$HOME/.bun/bin:$PATH"

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

if (("${#missing[@]}")); then
  sudo dnf -y install "${missing[@]}"
else
  echo "Yazi and Zellij already installed."
fi

echo
echo "==> Installing Bun $BUN_VERSION"

if [[ -x "$HOME/.bun/bin/bun" ]] && [[ "$("$HOME/.bun/bin/bun" --version)" == "$BUN_VERSION" ]]; then
  echo "Bun already installed: $BUN_VERSION"
else
  curl -fsSL https://bun.com/install | bash -s "bun-v$BUN_VERSION"
fi

echo
echo "==> Installing Typst $TYPST_VERSION"

if command -v typst >/dev/null 2>&1 && typst --version | grep -Fq "typst $TYPST_VERSION"; then
  echo "Typst already installed: $(command -v typst)"
else
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' EXIT

  curl -fL     "https://github.com/typst/typst/releases/download/v$TYPST_VERSION/typst-x86_64-unknown-linux-musl.tar.xz"     -o "$tmpdir/typst.tar.xz"

  tar -xJf "$tmpdir/typst.tar.xz" -C "$tmpdir"
  install -m 0755     "$tmpdir/typst-x86_64-unknown-linux-musl/typst"     "$BIN_DIR/typst"

  rm -rf "$tmpdir"
  trap - EXIT
fi

echo
echo "==> Installing Satty $SATTY_VERSION"

if command -v satty >/dev/null 2>&1 && satty --version 2>/dev/null | grep -Fq "$SATTY_VERSION"; then
  echo "Satty already installed: $(command -v satty)"
else
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' EXIT

  curl -fL \
    "https://github.com/Satty-org/Satty/releases/download/v$SATTY_VERSION/satty-x86_64-unknown-linux-gnu.tar.gz" \
    -o "$tmpdir/satty.tar.gz"

  echo "$SATTY_SHA256  $tmpdir/satty.tar.gz" | sha256sum -c -

  tar -xzf "$tmpdir/satty.tar.gz" -C "$tmpdir"
  satty_bin="$(find "$tmpdir" -type f -name satty -perm -u+x -print -quit)"

  [[ -n "$satty_bin" ]] || {
    echo "Satty binary not found in release archive" >&2
    exit 1
  }

  install -m 0755 "$satty_bin" "$BIN_DIR/satty"

  rm -rf "$tmpdir"
  trap - EXIT
fi

echo
echo "==> Installing Catppuccin GTK $CATPPUCCIN_GTK_VERSION"

THEME_DIR="$HOME/.local/share/themes/$CATPPUCCIN_GTK_THEME"

if [[ -f "$THEME_DIR/gtk-3.0/gtk.css" &&
      -f "$THEME_DIR/gtk-4.0/gtk.css" ]]; then
  echo "Catppuccin GTK already installed: $THEME_DIR"
else
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' EXIT

  curl -fL \
    "https://github.com/catppuccin/gtk/releases/download/v$CATPPUCCIN_GTK_VERSION/$CATPPUCCIN_GTK_THEME.zip" \
    -o "$tmpdir/theme.zip"

  echo "$CATPPUCCIN_GTK_SHA256  $tmpdir/theme.zip" | sha256sum -c -

  python3 -m zipfile -e "$tmpdir/theme.zip" "$tmpdir/extracted"

  src="$tmpdir/extracted/$CATPPUCCIN_GTK_THEME"
  [[ -d "$src" ]] || {
    echo "Catppuccin GTK theme missing from release archive: $src" >&2
    exit 1
  }

  mkdir -p "$HOME/.local/share/themes"
  rm -rf "$THEME_DIR"
  cp -a "$src" "$THEME_DIR"

  rm -rf "$tmpdir"
  trap - EXIT
fi

echo

echo "==> Installing wl-screenrec"

if command -v wl-screenrec >/dev/null 2>&1; then
  echo "wl-screenrec already available: $(command -v wl-screenrec)"
else
  cargo install --locked --root "$HOME/.local" wl-screenrec
fi

echo
echo "==> Installing wl-color-picker"

if command -v wl-color-picker >/dev/null 2>&1; then
  echo "wl-color-picker already available: $(command -v wl-color-picker)"
else
  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' EXIT

  curl -fL     https://raw.githubusercontent.com/jgmdev/wl-color-picker/main/wl-color-picker.sh     -o "$tmp"

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

  if [[ -f "$dist" ]] && ! find "$plugin_dir/src" "$plugin_dir/Cargo.toml" "$plugin_dir/Cargo.lock" -type f -newer "$dist" -print -quit 2>/dev/null | grep -q .; then
    echo "Zellij plugin already built: $name"
    return 0
  fi

  echo "Building: $name"
  cargo build     --manifest-path "$plugin_dir/Cargo.toml"     --locked     --release     --target wasm32-wasip1

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

for cmd in yazi zellij bun typst satty wl-screenrec wl-color-picker; do
  if command -v "$cmd" >/dev/null 2>&1; then
    printf 'OK   %-20s %s\n' "$cmd" "$(command -v "$cmd")"
  else
    printf 'FAIL %-20s missing\n' "$cmd" >&2
    failed=1
  fi
done

((failed == 0))


if command -v starship >/dev/null 2>&1; then
  echo "Starship already available: $(command -v starship)"
else
  echo "==> Starship"
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$BIN_DIR"
fi

echo "==> Installing Flyline"
FLYLINE_SO="$HOME/.local/lib/libflyline.so"
if [[ ! -f "$FLYLINE_SO" ]]; then
  flyline_tmp_home="$(mktemp -d)"
  trap 'rm -rf "$flyline_tmp_home"' EXIT

  env HOME="$flyline_tmp_home"       FLYLINE_INSTALL_DIR="$HOME/.local/lib"       bash <(curl -sSfL https://github.com/HalFrgrd/flyline/releases/latest/download/install.sh)

  rm -rf "$flyline_tmp_home"
  trap - EXIT
else
  echo "Flyline already installed: $FLYLINE_SO"
fi
