# Fedora 44 bootstrap target

Target distribution: Fedora Linux 44, x86_64.

Installation image: Fedora Everything 44 Network Install ISO.


## QEMU / KVM installation baseline

Use a libvirt-managed QEMU/KVM VM (virt-manager is fine) with UEFI firmware when available, VirtIO disk/network devices, and working network access.

Install a minimal Fedora 44 base from the Everything network installer. Do not add GNOME/KDE or extra desktop environments merely to make the VM boot. This repository owns the Niri session and its dependencies.

For clean VM power management, the Fedora guest must have qemu-guest-agent installed and enabled. ACPI shutdown is retained as a fallback. The bootstrap installs the guest-side packages and enables qemu-guest-agent.service.

On the host, virt-manager/libvirt should use Shut Down for graceful guest shutdown. Force Off is only a last resort when the guest is unresponsive.

## First boot

After the minimal Fedora installation:

```bash
sudo dnf -y install git
git clone https://github.com/orioninsist/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash install-fedora.sh
```

## Readiness rule

The Fedora target is not READY until all repository bootstrap, Niri session, user services, referenced binaries, QEMU graceful-shutdown checks, idempotency, and reboot acceptance tests pass.


## Test cycle

Before the first bootstrap test, keep a powered-off libvirt snapshot named `clean-fedora44`.
Run the bootstrap from the repository, collect `install/audit-fedora-target.sh`, and treat any pytest failure, missing required command, failed unit, or Niri validation error as a failed iteration.

Treat changes to the Fedora bootstrap as ready only after it succeeds twice consecutively (idempotency), the VM survives a reboot, Niri starts as a real session, portals work, and libvirt graceful shutdown works through qemu-guest-agent.




## Niri TTY session

The system does not use a display manager.
After login on a TTY, start the Wayland session manually:

```bash
niri-session

