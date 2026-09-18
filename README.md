# dotfiles

Personal Arch Linux / Sway configuration repository.

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
- `sway`
- `systemd`
- `waybar`
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
~/.config/sway   -> /mnt/local/projects/dotfiles/.config/sway
~/.config/waybar -> /mnt/local/projects/dotfiles/.config/waybar
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
