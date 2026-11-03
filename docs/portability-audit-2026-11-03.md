# Chezmoi portability audit — 2026-11-03

This document records source-level observations, not a successful clean-machine installation test.

## Changes in this branch

- Niri screenshot directory uses a home-relative path rather than a specific user's home directory.
- Espanso's user service uses systemd's `%h` specifier for the user's home directory and is bound to the graphical session. **Verify on the actual Fedora machine** that `~/.config/espanso/espanso` exists, is executable, and accepts `launcher`; the previously closed PR #3 reports a missing executable path.
- Rclone's one-time restore script fails when its age identity, encrypted snapshot, or `age` executable is unavailable. This avoids marking a skipped restore as successfully completed. Existing `rclone.conf` files and symlinks remain untouched. Restore the private age identity before applying configurations.

## Still open

1. **Secrets audit**: Inspect committed plaintext configurations and the full Git history with a dedicated scanner. `private_` only controls target permissions; it does not encrypt repository contents.
2. **Machine-specific paths**: Audit `dot_config/npm/private_npmrc`, `dot_config/gtk-3.0/bookmarks`, and other absolute paths. Do not convert npm's config blindly: test npm expansion semantics first.
3. **Bootstrap**: Package inventories contain Fedora hardware/system packages and third-party repositories. A package snapshot is not a tested cross-machine installer. Design a curated minimal package manifest and acceptance checks.
4. **Rclone**: The encrypted snapshot may contain outdated OAuth tokens. Verify functional authorization separately without exposing credentials.
5. **Clean install**: Verify `chezmoi init`, `chezmoi doctor`, `chezmoi apply --dry-run --verbose`, `niri validate` (if available), `systemd-analyze --user verify`, and service startup on Fedora, ideally in a test user or VM.
6. **Previous work**: PRs #2 and #3 were closed without merge. Review their unmerged changes instead of assuming the bootstrap or session fixes landed.

## Read-only local checks

```sh
chezmoi doctor
chezmoi status
chezmoi diff
chezmoi apply --dry-run --verbose
systemctl --user cat espanso.service
systemctl --user status espanso.service --no-pager
test -x "$HOME/.config/espanso/espanso" && echo "Espanso launcher exists"
git -C "$(chezmoi source-path)" status --short
```

Never post private age keys, decrypted rclone configurations, SSH private keys, or tokens in public logs or GitHub issues.
