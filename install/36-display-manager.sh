#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${DOTFILES_ROOT:?}"

source /etc/os-release
[[ "${ID:-}" == "fedora" ]] || { echo "Fedora required" >&2; exit 1; }

command -v ly >/dev/null || { echo "ly is required" >&2; exit 1; }
command -v niri-session >/dev/null || { echo "niri-session is required" >&2; exit 1; }
command -v semodule >/dev/null || { echo "semodule is required" >&2; exit 1; }

test -e /usr/lib/systemd/system/ly@.service || {
  echo "Missing Fedora Ly template unit: /usr/lib/systemd/system/ly@.service" >&2
  exit 1
}

test -e /usr/share/wayland-sessions/niri.desktop || {
  echo "Missing Niri Wayland session: /usr/share/wayland-sessions/niri.desktop" >&2
  exit 1
}

grep -Eq '^Exec=(/usr/(s)?bin/)?niri-session([[:space:]]|$)' /usr/share/wayland-sessions/niri.desktop || {
  echo "Invalid Niri session Exec entry" >&2
  exit 1
}

echo "Configuring Ly Niri session..."
niri_session_bin="$(command -v niri-session)"
sudo install -d -m 0755 /etc/ly/custom-sessions
sudo tee /etc/ly/custom-sessions/niri.desktop >/dev/null <<DESKTOP
[Desktop Entry]
Name=Niri
Comment=A scrollable-tiling Wayland compositor
Exec=$niri_session_bin
Type=Application
DesktopNames=niri
DESKTOP

policy_src="$ROOT/install/selinux/ly-local.te"
policy_makefile="/usr/share/selinux/devel/Makefile"
policy_stamp="/etc/ly/.ly-local-policy.sha256"
[[ -f "$policy_src" ]] || { echo "Missing SELinux policy source: $policy_src" >&2; exit 1; }
[[ -f "$policy_makefile" ]] || { echo "Missing SELinux development Makefile: $policy_makefile" >&2; exit 1; }

policy_hash="$(sha256sum "$policy_src" | awk '{print $1}')"
installed_hash="$(sudo cat "$policy_stamp" 2>/dev/null || true)"
if sudo semodule -l | grep -Eq '^ly-local([[:space:]]|$)' && [[ "$installed_hash" == "$policy_hash" ]]; then
  echo "Ly SELinux policy unchanged; skipping rebuild."
else
  echo "Installing Fedora Ly SELinux policy..."
  policy_tmp="$(mktemp -d)"
  trap 'rm -rf "$policy_tmp"' EXIT
  install -m 0644 "$policy_src" "$policy_tmp/ly-local.te"
  make -s -C "$policy_tmp" -f "$policy_makefile" ly-local.pp
  sudo semodule -i "$policy_tmp/ly-local.pp"
  sudo semodule -l | grep -Eq '^ly-local([[:space:]]|$)' || {
    echo "Ly SELinux policy installation verification failed" >&2
    exit 1
  }
  printf '%s\n' "$policy_hash" | sudo tee "$policy_stamp" >/dev/null
fi

if command -v getenforce >/dev/null; then
  selinux_mode="$(getenforce)"
  echo "SELinux mode: $selinux_mode"
  [[ "$selinux_mode" != "Disabled" ]] || {
    echo "SELinux must remain enabled; refusing a disabled SELinux configuration" >&2
    exit 1
  }
fi

echo "Configuring Ly systemd service..."
sudo systemctl disable gdm.service sddm.service lightdm.service 2>/dev/null || true
sudo systemctl disable getty@tty2.service 2>/dev/null || true
sudo systemctl enable ly@tty2.service
sudo systemctl set-default graphical.target

echo "Display manager configured: ly@tty2.service"
echo "Niri session entrypoint: $niri_session_bin"
echo "Ly SELinux policy: ly-local"
