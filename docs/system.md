# System configuration

This document describes the workstation configuration managed by the dotfiles repository.

## Package and application inventory

The Fedora package and application source of truth is:

```text
install/manifest.tsv
```

It includes Fedora packages, physical-machine-only packages, QEMU guest packages,
COPR packages, upstream tools, vendor applications, system and user services, and
conditional external projects.

Docker is the configured container engine. Podman is not part of the required target.

## Managed configuration

Shell configuration:

- `.bash_profile`
- `.bashrc`
- `.profile`

Desktop and application configuration includes Atuin, Eza, Kitty, GTK 3/4, Mako,
Neovim, Niri, Starship, Wayland helper scripts, systemd user units,
xdg-desktop-portal, Yazi, and Zellij.

Wallpapers are stored under `.wallpapers`.

Component-specific documentation:

- [Niri](../.config/niri/README.md)
- [orion-status Zellij plugin](../.config/zellij/plugins/orion-status/README.md)
- [ast-grep](../.config/ast-grep/README.md)

## Symlink model

Managed configuration is linked from the repository into `$HOME`.

```text
~/.bashrc        -> ~/dotfiles/.bashrc
~/.bash_profile  -> ~/dotfiles/.bash_profile
~/.profile       -> ~/dotfiles/.profile

~/.config/atuin  -> ~/dotfiles/.config/atuin
~/.config/kitty  -> ~/dotfiles/.config/kitty
~/.config/nvim   -> ~/dotfiles/.config/nvim
~/.config/niri   -> ~/dotfiles/.config/niri
~/.config/yazi   -> ~/dotfiles/.config/yazi
```

Because `~/.config/systemd` is repository-backed, live systemd enable symlinks
under `*.wants/` are runtime state and are ignored by Git. Do not delete those
directories merely to clean the working tree.

After moving an existing checkout:

```bash
cd ~/dotfiles
bash install/relink-moved-checkout.sh
```

The script locates the checkout from its own path, repairs links into an older
dotfiles checkout, and leaves unrelated links and regular files alone. It is only
a link repair; the full Fedora installer does not need to be rerun.

## User services

Required user units include:

```text
ssh-agent.service
swaybg.service
niri-keyboard-state.service
zellij-copy.path
```

The installer enables and starts required units immediately. Optional units are
enabled only when their executables are available; missing optional software is
not treated as an installation failure.

Knowledge services are conditional on:

```text
/home/murat/Media/6-Project/knowledge
```

If that project is absent, its services remain disabled.

## Google Drive read-only mounts

Google Drive is exposed as two user-owned FUSE mounts:

- `~/GoogleDrive` — personal Google Drive
- `~/GoogleDrive-Shared` — files visible through "Shared with me"

Both mounts are intentionally read-only. They must never be used for upload,
delete, rename, or synchronization operations.

The mounts use `--vfs-cache-mode off`, so rclone does not maintain a persistent
VFS file cache. File contents are fetched when accessed. Directory metadata may
be cached briefly in memory and refreshed through Google Drive polling.

The systemd user services are:

- `rclone-gdrive.service`
- `rclone-gdrive-shared.service`

When rclone configuration exists, the services are enabled for future
login/reboot sessions and restart automatically after failures. Backup and
synchronization are deliberately separate from these mounts.

## Niri, Ly and SELinux

SELinux must remain enabled. The Fedora bootstrap installs the local Ly SELinux
policy from:

```text
install/selinux/ly-local.te
```

Do not work around Ly session problems by disabling SELinux or permanently
switching the machine to permissive mode.

Niri configuration can be checked with:

```bash
niri validate
```

See [Niri configuration](../.config/niri/README.md) for the complete workspace,
shortcut, conflict, and validation reference.

## PATH application sync

The launcher flow is:

```text
Super+D -> Fuzzel -> PATH command
```

After installing a GUI application or Chrome/Chromium PWA:

```bash
path-apps sync
```

The helper scans desktop entries and creates wrappers under `~/.local/bin`
when needed without removing existing desktop entries or PWA registrations.

## Espanso

Espanso configuration is tracked under `.config/espanso/`. Its service is
optional during bootstrap: when the executable is unavailable,
`espanso.service` is skipped rather than failing Fedora acceptance tests.

Custom match files live under `.config/espanso/match/`.

The helper:

```text
.config/wayland/scripts/commands/espanso-word
```

opens or creates topic YAML files.

## Desktop appearance

- System color preference: dark
- GTK 3/4 theme: Catppuccin Mocha/Mauve
- Wallpaper is managed from `.wallpapers` by `swaybg.service`
