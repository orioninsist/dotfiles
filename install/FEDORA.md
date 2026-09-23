# Fedora bootstrap target

Target distribution: Fedora Linux 44, x86_64.

Installation image: Fedora Everything 44 Network Install ISO.

The existing Arch source-system audit remains the migration inventory.
Debian-specific bootstrap work is retained on the bootstrap-debian branch and is not the target of this branch.

## Installation baseline

Use the Fedora Everything network installer in QEMU with working network access.
Keep the base installation minimal; the repository bootstrap will own the Niri environment and required packages.

## Readiness rule

The Fedora target is not considered ready until repository bootstrap, user services, Niri session, referenced binaries, idempotency, and reboot acceptance tests pass.
