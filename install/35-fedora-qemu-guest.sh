#!/usr/bin/env bash
set -Eeuo pipefail

source /etc/os-release
[[ "${ID:-}" == "fedora" ]] || { echo "Fedora required" >&2; exit 1; }

if systemd-detect-virt --quiet --vm; then
  # qemu-guest-agent needs the libvirt virtio-serial channel
  # org.qemu.guest_agent.0. If the host has no such channel, installing
  # packages inside the guest cannot create it.
  if [[ -e /dev/virtio-ports/org.qemu.guest_agent.0 ]]; then
    sudo systemctl enable --now qemu-guest-agent.service
    systemctl is-active --quiet qemu-guest-agent.service
  else
    echo "WARNING: QEMU guest-agent channel is missing: /dev/virtio-ports/org.qemu.guest_agent.0" >&2
    echo "Add the org.qemu.guest_agent.0 channel to this VM in libvirt/virt-manager." >&2
  fi

  # SPICE guest integration. The package supplies system and graphical-session
  # units; socket activation is preferred over forcing the desktop agent here.
  if systemctl cat spice-vdagentd.socket >/dev/null 2>&1; then
    sudo systemctl enable --now spice-vdagentd.socket
  fi
else
  echo "Not a virtual machine; skipping QEMU/SPICE guest integration."
fi
