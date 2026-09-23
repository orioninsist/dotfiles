# Fedora 44 bootstrap target

Target distribution: Fedora Linux 44, x86_64.

Installation image: Fedora Everything 44 Network Install ISO.

The existing Arch source-system audit remains the migration inventory. Debian-specific bootstrap work remains isolated on the bootstrap-debian branch and is not the target here.

## QEMU / KVM installation baseline

Use a libvirt-managed QEMU/KVM VM (virt-manager is fine) with UEFI firmware when available, VirtIO disk/network devices, and working network access.

Install a minimal Fedora 44 base from the Everything network installer. Do not add GNOME/KDE or extra desktop environments merely to make the VM boot. This repository owns the Niri session and its dependencies.

For clean VM power management, the Fedora guest must have qemu-guest-agent installed and enabled. ACPI shutdown is retained as a fallback. The bootstrap installs the guest-side packages and enables qemu-guest-agent.service.

On the host, virt-manager/libvirt should use Shut Down for graceful guest shutdown. Force Off is only a last resort when the guest is unresponsive.

## First boot

After the minimal Fedora installation:

```bash
sudo dnf -y install git
git clone --branch bootstrap-fedora https://github.com/orioninsist/dotfiles.git /mnt/local/projects/dotfiles
cd /mnt/local/projects/dotfiles
bash bootstrap.sh
```

If /mnt/local/projects is not part of the final filesystem design, stop before bootstrap and adjust the repo path strategy first: several current dotfiles still intentionally reference that location.

## Readiness rule

The Fedora target is not READY until all repository bootstrap, Niri session, user services, referenced binaries, QEMU graceful-shutdown checks, idempotency, and reboot acceptance tests pass.
