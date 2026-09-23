#!/usr/bin/env bash
set -Eeuo pipefail

source /etc/os-release
[[ "${ID:-}" == "fedora" ]] || { echo "Fedora required" >&2; exit 1; }

if systemd-detect-virt --quiet --vm; then
  sudo systemctl enable --now qemu-guest-agent.service
  systemctl is-active --quiet qemu-guest-agent.service
else
  echo "Not a virtual machine; skipping qemu-guest-agent enablement."
fi
