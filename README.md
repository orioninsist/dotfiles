# dotfiles

Personal Fedora Linux 44 / Niri configuration and bootstrap repository.

The active checkout is expected at:

```text
~/dotfiles
```

The repository manages shell configuration, Niri, Wayland helpers, user/system services, package parity, desktop applications, and Fedora-specific bootstrap/verification.

## Target

Validated target:

- Fedora Linux 44, x86_64
- Niri Wayland compositor
- Ly display manager
- SELinux Enforcing
- NetworkManager
- PipeWire / WirePlumber
- Fedora physical-machine and QEMU/KVM profiles

The previous Arch Linux state is preserved by the Git tag:

```text
arch-final-2026-09-23
```

## Installation

For a fresh Fedora 44 system:

```bash
sudo dnf -y install git
git clone https://github.com/orioninsist/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash install-fedora.sh
```

The installer runs these phases:

1. preflight checks
2. Fedora packages
3. external tools
4. vendor applications
5. fonts
6. dotfiles installation
7. user services
8. system services
9. QEMU guest integration when applicable
10. Ly / Niri session / SELinux setup
11. acceptance tests

The lower-level Fedora bootstrap is also available as:

```bash
bash bootstrap.sh
```

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

The test suite also verifies required commands, Niri/Ly integration, dotfile links, required user units, desktop integration, system-service parity, and the Fedora package profile.

## Package and application inventory

The Fedora package/application source of truth is:

```text
install/manifest.tsv
```

It includes:

- Fedora packages
- physical-machine-only packages
- QEMU guest packages
- COPR packages
- upstream tools
- vendor applications
- system and user services
- conditional external projects

Docker is the configured container engine. Podman is not part of this repository's required target.

## Managed configuration

Shell:

- `.bash_profile`
- `.bashrc`
- `.profile`

Desktop and applications include:

- Atuin
- Eza
- Foot
- GTK 3/4
- Mako
- Neovim
- Niri
- Starship
- Wayland helper scripts
- systemd user units
- xdg-desktop-portal
- Yazi
- Zellij

Wallpapers are stored under `.wallpapers`.

## Symlink model

Managed configuration is linked from the repository into `$HOME`.

Examples:

```text
~/.bashrc        -> ~/dotfiles/.bashrc
~/.bash_profile  -> ~/dotfiles/.bash_profile
~/.profile       -> ~/dotfiles/.profile

~/.config/atuin  -> ~/dotfiles/.config/atuin
~/.config/foot   -> ~/dotfiles/.config/foot
~/.config/nvim   -> ~/dotfiles/.config/nvim
~/.config/niri   -> ~/dotfiles/.config/niri
~/.config/yazi   -> ~/dotfiles/.config/yazi
```

Because `~/.config/systemd` is repository-backed, live systemd enable symlinks under `*.wants/` are runtime state and are ignored by Git. Do not delete those directories merely to clean the working tree.

## User services

Required user units include:

```text
ssh-agent.service
swayidle.service
niri-keyboard-state.service
zellij-copy.path
```

Optional units are enabled only when their executables are available. Missing optional software is not treated as an installation failure.

The Knowledge services are conditional on:

```text
/mnt/projects/knowledge
```

If that project is absent, its services remain disabled.

## Niri, Ly and SELinux

SELinux must remain enabled.

The Fedora bootstrap installs the local Ly SELinux policy from:

```text
install/selinux/ly-local.te
```

Do not work around Ly session problems by disabling SELinux or switching the machine permanently to permissive mode.

Niri configuration can be checked independently with:

```bash
niri validate
```

## PATH application sync

This setup uses a PATH-oriented launcher flow:

```text
Super+D -> fzf -> PATH command
```

After installing a GUI application or Chrome/Chromium PWA, run:

```bash
path-apps sync
```

The helper scans desktop entries and creates wrappers under `~/.local/bin` when needed without removing existing desktop entries or PWA registrations.

## Espanso

Espanso configuration is tracked under:

```text
.config/espanso/
```

Its service is optional during bootstrap: if the Espanso executable is not installed, `espanso.service` is skipped rather than failing the Fedora acceptance tests.

Custom match files live under:

```text
.config/espanso/match/
```

The helper:

```text
.local/bin/espanso-word
```

opens or creates topic YAML files.

## Dotfiles workflow

Inspect changes:

```bash
cd ~/dotfiles
git status --short
git diff
```

After verification:

```bash
git add <files>
git commit -m "Describe the change"
git push origin main
```

Confirm local and GitHub `main` are synchronized:

```bash
git fetch origin --prune
git rev-list --left-right --count main...origin/main
```

Expected:

```text
0  0
```

## Migration notes

Fedora is now the active `main` branch target.

Historical Arch state remains recoverable from:

```text
arch-final-2026-09-23
```

Private/user data is intentionally not restored by the dotfiles bootstrap. Restore personal data and secrets separately from the private backup, after verifying paths and checksums.

### Desktop appearance

- System color preference: dark
- GTK 3/4 theme: Catppuccin Mocha/Mauve
- Wallpaper is managed from `.wallpapers` by `swaybg.service`.
