#!/usr/bin/env bash
set -Eeuo pipefail

BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

install_dnf_repo_package() {
  local repo_url="$1" package="$2"
  if rpm -q "$package" >/dev/null 2>&1; then
    echo "OK $package already installed"
    return
  fi
  sudo dnf -y install dnf-plugins-core
  sudo dnf config-manager addrepo --from-repofile="$repo_url"
  sudo dnf -y install "$package"
}

echo "==> Official vendor repositories"

install_dnf_repo_package   "https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo"   brave-browser

install_dnf_repo_package   "https://repository.mullvad.net/rpm/stable/mullvad.repo"   mullvad-browser



if ! rpm -q google-chrome-stable >/dev/null 2>&1; then
  tmp_rpm="$(mktemp --suffix=.rpm)"
  trap 'rm -f "$tmp_rpm"' RETURN
  curl -fL https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm -o "$tmp_rpm"
  sudo dnf -y install "$tmp_rpm"
  rm -f "$tmp_rpm"
  trap - RETURN
fi

if ! rpm -q microsoft-edge-stable >/dev/null 2>&1; then
  sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
  sudo tee /etc/yum.repos.d/microsoft-edge.repo >/dev/null <<'REPO'
[microsoft-edge]
name=Microsoft Edge
baseurl=https://packages.microsoft.com/yumrepos/edge-stable/
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
REPO
  sudo dnf -y install microsoft-edge-stable
fi

if ! rpm -q code >/dev/null 2>&1; then
  sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
  sudo tee /etc/yum.repos.d/vscode.repo >/dev/null <<'REPO'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
REPO
  sudo dnf -y install code
fi



if ! rpm -q yandex-browser-stable >/dev/null 2>&1; then
  sudo rpmkeys --import https://repo.yandex.ru/yandex-browser/YANDEX-BROWSER-KEY.GPG
  sudo dnf config-manager addrepo --id=yandex-browser --set=baseurl=https://repo.yandex.ru/yandex-browser/rpm/stable/x86_64
  sudo dnf -y install yandex-browser-stable
fi

if ! rpm -q antigravity >/dev/null 2>&1; then
  sudo tee /etc/yum.repos.d/antigravity.repo >/dev/null <<'REPO'
[antigravity-rpm]
name=Antigravity RPM Repository
baseurl=https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-rpm
enabled=1
gpgcheck=0
REPO
  sudo dnf -y makecache
  sudo dnf -y install antigravity
fi


TOR_VERSION="15.0.23"
TOR_DIR="$HOME/.local/opt/tor-browser"
if [[ ! -x "$TOR_DIR/Browser/start-tor-browser" ]]; then
  echo "==> Tor Browser $TOR_VERSION"
  mkdir -p "$HOME/.local/opt"
  tmp_tor="$(mktemp --suffix=.tar.xz)"
  curl -fL "https://dist.torproject.org/torbrowser/$TOR_VERSION/tor-browser-linux-x86_64-$TOR_VERSION.tar.xz" -o "$tmp_tor"
  rm -rf "$TOR_DIR"
  tar -xJf "$tmp_tor" -C "$HOME/.local/opt"
  mv "$HOME/.local/opt/tor-browser" "$TOR_DIR" 2>/dev/null || true
  rm -f "$tmp_tor"
  "$TOR_DIR/start-tor-browser.desktop" --register-app || true
fi


REALESRGAN_VERSION="0.2.5.0"
REALESRGAN_BUILD="20220424"
REALESRGAN_DIR="$HOME/.local/opt/realesrgan-ncnn-vulkan"
if [[ ! -x "$REALESRGAN_DIR/realesrgan-ncnn-vulkan" ]]; then
  echo "==> Real-ESRGAN NCNN/Vulkan"
  mkdir -p "$HOME/.local/opt" "$BIN_DIR"
  tmp_realesrgan="$(mktemp --suffix=.zip)"
  tmp_realesrgan_dir="$(mktemp -d)"
  curl -fL "https://github.com/xinntao/Real-ESRGAN/releases/download/v$REALESRGAN_VERSION/realesrgan-ncnn-vulkan-$REALESRGAN_BUILD-ubuntu.zip" -o "$tmp_realesrgan"
  unzip -q "$tmp_realesrgan" -d "$tmp_realesrgan_dir"
  rm -rf "$REALESRGAN_DIR"
  mkdir -p "$REALESRGAN_DIR"
  cp -a "$tmp_realesrgan_dir"/. "$REALESRGAN_DIR"/
  chmod +x "$REALESRGAN_DIR/realesrgan-ncnn-vulkan"
  ln -sfn "$REALESRGAN_DIR/realesrgan-ncnn-vulkan" "$BIN_DIR/realesrgan-ncnn-vulkan"
  rm -rf "$tmp_realesrgan" "$tmp_realesrgan_dir"
fi


if ! rpm -q chatgpt >/dev/null 2>&1; then
  echo "==> ChatGPT Desktop (official OpenAI Fedora RPM)"
  tmp_chatgpt="$(mktemp --suffix=.rpm)"
  curl --proto '=https' --tlsv1.2 -fL     https://persistent.oaistatic.com/codex-app-prod/linux/rpm/latest/chatgpt.x86_64.rpm     -o "$tmp_chatgpt"
  sudo dnf -y install "$tmp_chatgpt"
  rm -f "$tmp_chatgpt"
fi


COPILOT_APP_DIR="$HOME/.local/opt/github-copilot"
COPILOT_APP="$COPILOT_APP_DIR/github-copilot.AppImage"
if [[ ! -x "$COPILOT_APP" ]]; then
  echo "==> GitHub Copilot App"
  mkdir -p "$COPILOT_APP_DIR" "$BIN_DIR" "$HOME/.local/share/applications"
  copilot_api="https://api.github.com/repos/github/app/releases/latest"
  copilot_url="$(curl -fsSL "$copilot_api" | jq -r '
    [.assets[]
      | select(.name | test("linux.*(x64|x86_64|amd64).*\\.AppImage$"; "i"))][0].browser_download_url // empty
  ')"
  [[ -n "$copilot_url" ]] || {
    echo "Unable to resolve official GitHub Copilot Linux x86_64 AppImage." >&2
    exit 1
  }
  curl -fL "$copilot_url" -o "$COPILOT_APP"
  chmod +x "$COPILOT_APP"
  ln -sfn "$COPILOT_APP" "$BIN_DIR/github-copilot-app"
  cat > "$HOME/.local/share/applications/github-copilot-app.desktop" <<DESKTOP
[Desktop Entry]
Name=GitHub Copilot
Comment=GitHub Copilot
Exec=$COPILOT_APP
Terminal=false
Type=Application
Categories=Development;
DESKTOP
fi

echo "==> Official user-local developer tools"

if ! command -v claude >/dev/null 2>&1; then
  curl -fsSL https://claude.ai/install.sh | bash
fi

if ! command -v copilot >/dev/null 2>&1; then
  curl -fsSL https://gh.io/copilot-install | PREFIX="$HOME/.local" bash
fi

echo
echo "Vendor phase installed methods that are fully documented for Fedora/Linux."
echo "Remaining portable tarball/release applications are installed by the upstream-app phase; Spotify remains an explicit no-native-Fedora exception."
