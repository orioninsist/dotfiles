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
