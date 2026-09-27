# Recovery and maintenance

This document covers repository maintenance and Fedora system-state recovery.

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

## Private data recovery

Private and user data is intentionally not restored by the dotfiles bootstrap.
Restore personal data and secrets separately from the private backup after
verifying paths and checksums.

## Continuous system-state reconciliation

The user timer `orion-system-state-sync.timer` periodically records the current
Fedora RPM package set, Flatpak applications, enabled system/user services, and
stable host identity into `state/`.

When generated manifests change, it creates a commit and pushes it to the
configured `origin` remote. It deliberately does not collect secrets, personal
files, Google Drive, or rclone data.

Run it manually with:

```bash
~/dotfiles/install/recovery/sync-system-state.sh
```

Use `--no-push` for a local commit or `--dry-run` to inspect changes without
a commit.

A fresh Fedora installation can use the repository bootstrap flow and then
install packages from the generated manifests during the recovery phase.
