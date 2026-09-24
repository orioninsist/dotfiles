#!/usr/bin/env bash
set -Eeuo pipefail

source /etc/os-release
[[ "${ID:-}" == "fedora" ]] || { echo "Fedora required" >&2; exit 1; }

if systemd-detect-virt --quiet --vm; then
  if [[ -e /dev/virtio-ports/org.qemu.guest_agent.0 ]]; then
    if ! systemctl is-active --quiet qemu-guest-agent.service; then
      sudo systemctl start qemu-guest-agent.service
    fi
    systemctl is-active --quiet qemu-guest-agent.service
  else
    echo "WARNING: QEMU guest-agent channel is missing: /dev/virtio-ports/org.qemu.guest_agent.0" >&2
    echo "Add the org.qemu.guest_agent.0 channel to this VM in libvirt/virt-manager." >&2
  fi

  if systemctl cat spice-vdagentd.socket >/dev/null 2>&1; then
    if ! systemctl is-active --quiet spice-vdagentd.socket; then
      sudo systemctl start spice-vdagentd.socket
    fi
  fi
else
  echo "Not a virtual machine; skipping QEMU/SPICE guest integration."
fi
