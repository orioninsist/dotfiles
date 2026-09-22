# dotfiles

Personal Arch Linux / Niri configuration repository.

The active configuration is managed from `/mnt/local/projects/dotfiles` and linked into `$HOME` with symbolic links. This keeps the Git repository and the live configuration in sync.

## Managed configuration

Shell:

- `.bash_profile`
- `.bashrc`
- `.profile`

Desktop and applications:

- `atuin`
- `eza`
- `foot`
- `fuzzel`
- `gtk-3.0`
- `gtk-4.0`
- `mako`
- `nvim`
- `niri`
- `wayland`
- `systemd`
- `xdg-desktop-portal`
- `yazi`

Wallpapers are stored under `.wallpapers`.

## Symlink model

The live files point directly to this repository instead of being copied.

Examples:

```text
~/.bashrc       -> /mnt/local/projects/dotfiles/.bashrc
~/.bash_profile -> /mnt/local/projects/dotfiles/.bash_profile
~/.profile      -> /mnt/local/projects/dotfiles/.profile

~/.config/atuin  -> /mnt/local/projects/dotfiles/.config/atuin
~/.config/eza    -> /mnt/local/projects/dotfiles/.config/eza
~/.config/foot   -> /mnt/local/projects/dotfiles/.config/foot
~/.config/nvim   -> /mnt/local/projects/dotfiles/.config/nvim
~/.config/niri   -> /mnt/local/projects/dotfiles/.config/niri
~/.config/wayland -> /mnt/local/projects/dotfiles/.config/wayland
~/.config/yazi   -> /mnt/local/projects/dotfiles/.config/yazi
```

Some single configuration files, such as GTK and xdg-desktop-portal settings, are linked individually.

Because these are symbolic links, changes made in the repository become the active configuration immediately.

## Flyline

Flyline is built from source from the local checkout:

```text
/mnt/local/projects/flyline
```

Bash loads the release library from:

```text
/mnt/local/projects/flyline/target/release/libflyline.so
```

The Flyline builtin is loaded only in interactive Bash sessions.

The current shell configuration also integrates Flyline with Atuin:

- `Ctrl+R` opens Atuin history search.
- `Up` uses Atuin history navigation.

Official Flyline documentation:

https://github.com/HalFrgrd/flyline

## Updating Flyline

Update the source checkout and build the release artifact:

```bash
cd /mnt/local/projects/flyline

git fetch upstream
git merge --ff-only upstream/master
git push origin master

cargo build --release --locked
```

Open a new interactive Bash session after rebuilding, then verify:

```bash
flyline version
```

## Dotfiles workflow

Inspect changes before committing:

```bash
cd /mnt/local/projects/dotfiles
git status --short
git diff
```

After verification:

```bash
git add <files>
git commit -m "Describe the change"
git push origin main
```

Confirm the local branch and GitHub are synchronized:

```bash
git fetch origin --prune
git rev-list --left-right --count main...origin/main
```

Expected result:

```text
0  0
```

## Espanso

Espanso is the permanent local text-expansion layer for this setup. It is intentionally file-based and local-first: YAML files are edited locally, become active immediately, and are committed to Git only after verification.

Live structure:

```text
~/.config/espanso/match/
├── packages/
├── storage/
└── custom -> /mnt/local/projects/dotfiles/.config/espanso/match/
```

Custom matches live in:

```text
/mnt/local/projects/dotfiles/.config/espanso/match/
├── base.yml
├── openai.yml
└── <topic>.yml
```

Espanso loads match files recursively, so creating or editing a topic YAML file under the repository is enough. No per-file symlink, database, manager application, index, deploy step, or synchronization script is required.

The daily workflow is:

```text
edit/add/remove YAML
        ↓
Espanso reloads the configuration
        ↓
Super+C
        ↓
Fuzzel: YAML match files + active trigger count
        ↓
select a match file
        ↓
Fuzzel: triggers from that file
        ↓
select a trigger
        ↓
expand the selected match into the active application
```

The Espanso picker is intentionally hierarchical. The first Fuzzel view treats each custom YAML match file as a category and shows its active trigger count. The second view contains only the active triggers from the selected file. Both views enable Fuzzel's match counter, so filtering shows the current match count against the total. Empty match files are omitted. This keeps the picker usable as the number of topic files and triggers grows without adding a separate database or index.

The repository is the versioned source, while the local checkout is the live runtime source. GitHub is used for backup, history, and rollback rather than as a runtime dependency.

Current Espanso defaults are intentionally minimal:

```yaml
enable: true
backend: inject
show_notifications: false
auto_restart: true

keyboard_layout:
  rules: evdev
  model: pc105
  layout: us
  variant: ""
  options: ""
```

Notes:

- `enable: true` keeps Espanso enabled.
- `backend: inject` forces direct key-event text injection instead of clipboard injection.
- `show_notifications: false` disables Espanso notifications.
- `auto_restart: true` refreshes the worker automatically when configuration files change on disk.
- The explicit `keyboard_layout` block pins the Wayland keyboard layout to the current evdev / pc105 / US setup.

Do not add extra tuning unless a real reproducible problem appears. In particular, injection delays and modifier delays should remain at Espanso defaults unless a specific application starts losing characters or mis-handling injected key events.

For day-to-day changes:

```bash
cd /mnt/local/projects/dotfiles
$EDITOR .config/espanso/match/<topic>.yml
espanso match list
git diff
git add .config/espanso
git commit -m "Update Espanso matches"
git push origin main
```

