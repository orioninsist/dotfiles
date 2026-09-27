# OO7 Secret Service

## Final state

- Secret Service provider: `oo7-daemon`
- D-Bus name: `org.freedesktop.secrets`
- Display manager: `Ly`
- Wayland compositor: `Niri`
- GNOME Keyring removed
- PAM integration uses `pam_oo7.so`

## Migration notes

The previous GNOME Keyring PAM references were replaced with OO7:

- `/etc/pam.d/ly`
- `/etc/pam.d/ly-autologin`
- `/etc/pam.d/passwd`

Backup was created before the PAM change.

## Validation

Checked after reboot:

- `oo7-daemon.service` enabled and running
- `org.freedesktop.secrets` owned by `oo7-daemon`
- no `gnome-keyring` process/package remaining
- Chrome/Google Chat no longer requested an additional keyring password

This topic is considered closed. Future keyring work should use OO7 as the only Secret Service implementation.
