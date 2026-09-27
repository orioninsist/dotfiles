# dotfiles

Personal Fedora Linux 44 / Niri configuration and bootstrap repository.

The repository is the reproducible source for my workstation configuration:
shell setup, Niri and Wayland tooling, desktop applications, user/system
services, package parity, Fedora bootstrap, verification, and recovery state.

The checkout can live anywhere. On the current machine the canonical checkout is:

```text
~/dotfiles
```

`/home/murat/Media/6-Project` is the canonical root for related project
checkouts. The dotfiles repository itself is kept in `$HOME`.

## Target

Validated target:

- Fedora Linux 44, x86_64
- Niri Wayland compositor
- Ly display manager
- SELinux Enforcing
- NetworkManager
- PipeWire / WirePlumber
- Fedora physical-machine and QEMU/KVM profiles

The previous Arch Linux state is preserved by the Git tag
`arch-final-2026-09-23`.

## Installation

For a fresh Fedora 44 system:

```bash
sudo dnf -y install git
git clone https://github.com/orioninsist/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash install-fedora.sh
```

The lower-level bootstrap entry point is also available as:

```bash
bash bootstrap.sh
```

For the Fedora target, VM baseline, readiness rules, and Ly/SELinux notes, see
[install/FEDORA.md](install/FEDORA.md).

## Verification

Run the full acceptance checks with:

```bash
cd ~/dotfiles
export DOTFILES_ROOT="$PWD"
bash install/40-verify.sh
```

A successful installation currently ends with:

```text
VERIFY_EXIT=0
NIRI=PASS
LY=enabled
SELINUX=Enforcing
FAILED_UNITS=0
```

## Documentation

| Topic | Document |
|---|---|
| Managed configuration, symlinks, services, Google Drive, PATH apps, Espanso | [docs/system.md](docs/system.md) |
| Recovery, Git workflow, migration history, system-state reconciliation | [docs/recovery.md](docs/recovery.md) |
| Fedora 44 bootstrap target and acceptance rules | [install/FEDORA.md](install/FEDORA.md) |
| Niri workspaces, shortcuts, window model and validation | [.config/niri/README.md](.config/niri/README.md) |
| Zellij `orion-status` plugin | [.config/zellij/plugins/orion-status/README.md](.config/zellij/plugins/orion-status/README.md) |
| ast-grep shell and project configuration | [.config/ast-grep/README.md](.config/ast-grep/README.md) |
| Historical source-system audit | [audit/current-system/README.md](audit/current-system/README.md) |

## Repository map

```text
.config/       Application and desktop configuration
.local/        User-local scripts and files
.wallpapers/   Wallpapers
audit/         Historical and system audits
docs/          Repository-level documentation
install/       Fedora bootstrap, verification and recovery tooling
state/         Generated reproducible system state
tests/         Verification tests
```

The Fedora package and application source of truth is
[`install/manifest.tsv`](install/manifest.tsv).

## License

[MIT](LICENSE)
