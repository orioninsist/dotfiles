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


## Test cycle

Before the first bootstrap test, keep a powered-off libvirt snapshot named `clean-fedora44`.
Run the bootstrap from the repository, collect `install/audit-fedora-target.sh`, and treat any pytest failure, missing required command, failed unit, or Niri validation error as a failed iteration.

Do not merge the Fedora branch until the bootstrap succeeds twice consecutively (idempotency), the VM survives a reboot, Niri starts as a real session, portals work, and libvirt graceful shutdown works through qemu-guest-agent.


## Ly and SELinux

Fedora SELinux must remain enabled. On Fedora 44, Ly can authenticate successfully but fail to start the user session when SELinux denies the process transition from `unconfined_service_t` to `unconfined_t`.

The bootstrap installs `selinux-policy-devel`, builds the repository-owned policy source at `install/selinux/ly-local.te`, and installs it as the `ly-local` SELinux module before enabling Ly. The policy is intentionally minimal and grants only the process transition observed and verified on the Fedora 44 target.

Do not work around Ly login failures by disabling SELinux or switching the machine to permissive mode. Verification requires the `ly-local` module to be present and SELinux not to be disabled.
