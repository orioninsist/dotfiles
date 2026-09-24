# Niri configuration

Modular Niri configuration for the daily Wayland session.

## Fedora / systemd session model

On Fedora, the packaged desktop entry launches `niri-session`, which imports the login environment and starts the packaged `niri.service`. The service in turn brings up `graphical-session.target` and `xdg-desktop-autostart.target`.

Long-running desktop helpers are therefore managed as user systemd services instead of `spawn-at-startup`. This repo keeps only short one-shot session setup in `config.kdl`.

Expected graphical-session services include:

- `mako.service`
- `cliphist.service`
- `swaybg.service`
- `swayidle.service`
- `espanso.service`
- `easyeffects.service`
- `orion-audio-state.service`
- `orion-power-profile-state.service`

After linking the dotfiles on a new machine:

```sh
systemctl --user daemon-reload
systemctl --user enable mako.service cliphist.service swaybg.service swayidle.service
systemctl --user enable espanso.service easyeffects.service
systemctl --user enable orion-audio-state.service orion-power-profile-state.service
```

The services use portable command discovery where package locations can differ between Arch and Fedora. Missing optional programs should be installed before enabling their service.

## Structure

| File | Responsibility |
|---|---|
| `config.kdl` | Input, outputs, layout, one-shot startup, workspaces, window rules and includes |
| `binds/window-management.kdl` | Niri-native window, column, monitor and layout actions |
| `binds/workspaces.kdl` | Workspace navigation, movement and wheel navigation |
| `binds/system.kdl` | Audio, media, brightness, capture, hardware, notifications and session |
| `binds/applications.kdl` | Personal application launchers only |
| `../systemd/user/*.service` | Long-running graphical-session services |

Niri 26.04 supports `include`, so the main config stays small while each binding domain remains independently maintainable.

## Validation

After pulling locally:

```sh
niri validate -c ~/.config/niri/config.kdl
systemd-analyze --user verify ~/.config/systemd/user/*.service
```

To reload while Niri is running:

```sh
niri msg action load-config-file
```

To inspect session failures:

```sh
systemctl --user --failed
journalctl --user -b -p warning..alert
```
