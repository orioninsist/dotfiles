# Niri configuration

Modular Niri configuration for the daily Wayland session.

## Table of contents

- [Structure](#structure)
- [Window management](#window-management)
- [Workspaces](#workspaces)
- [Personal applications](#personal-applications)
- [System and utilities](#system-and-utilities)
- [Conflict policy](#conflict-policy)
- [Validation](#validation)

## Structure

| File | Responsibility |
|---|---|
| `config.kdl` | Input, outputs, layout, startup, workspaces, window rules and includes |
| `binds/window-management.kdl` | Niri-native window, column, monitor and layout actions |
| `binds/workspaces.kdl` | Workspace navigation, movement and wheel navigation |
| `binds/system.kdl` | Audio, media, brightness, capture, hardware, notifications and session |
| `binds/applications.kdl` | Personal application launchers only |

Niri 26.04 supports `include`, so the main config stays small while each binding domain remains independently maintainable.

## Window management

The window-management module follows Niri's upstream model: columns scroll horizontally, multiple windows may live vertically in a column, and monitors/workspaces are first-class navigation targets.

| Shortcut | Action |
|---|---|
| `Super+Shift+/` | Hotkey overlay |
| `Super+O` | Overview |
| `Super+Shift+Q` | Close window |
| `Super+H/J/K/L` or arrows | Focus columns/windows |
| `Super+Shift+H/J/K/L` or arrows | Move columns/windows; retained muscle memory |
| `Super+Ctrl+H/J/K/L` or arrows | Niri upstream-style move columns/windows |
| `Super+Home/End` | First/last column |
| `Super+Ctrl+Home/End` | Move column to first/last |
| `Super+Ctrl+Shift+H/J/K/L` or arrows | Move column between monitors |
| `Super+[/]` | Consume/expel window left/right |
| `Super+, / .` | Consume into / expel from column |
| `Super+R` | Next preset column width |
| `Super+Shift+R` | Previous preset column width |
| `Super+Ctrl+Shift+R` | Cycle preset window height |
| `Super+Ctrl+R` | Reset window height |
| `Super+-/+` | Adjust column width |
| `Super+Shift+-/+` | Adjust window height |
| `Super+F` | Fullscreen; retained muscle memory |
| `Super+M` | Maximize window to screen edges |
| `Super+Alt+F` | Expand column to available width |
| `Super+Alt+C` | Center focused column |
| `Super+Alt+Ctrl+C` | Center visible columns |
| `Super+V` | Toggle floating |
| `Super+Space` | Focus floating/tiling |
| `Super+W` | Toggle tabbed column display |
| `Super+Escape` | Toggle keyboard-shortcut inhibition escape hatch |

## Workspaces

| Shortcut | Action |
|---|---|
| `Super+1..9,0` | Focus workspace 1..10 |
| `Super+Shift+1..9,0` | Move column to workspace 1..10 |
| `Super+Tab` | Previous workspace |
| `Super+PageUp/PageDown` | Workspace up/down |
| `Super+U` | Workspace down |
| `Super+Ctrl+PageUp/PageDown` | Move column to workspace up/down |
| `Super+Ctrl+U/I` | Move column to workspace down/up |
| `Super+Shift+PageUp/PageDown` | Reorder workspace |
| `Super+Shift+U` | Move workspace down |
| `Super+Wheel` | Navigate workspaces/columns |
| `Super+Ctrl+Wheel` | Move columns across workspaces/columns |

Workspace placement remains:
- HDMI-A-1: 1-5
- eDP-1: 6-10

## Personal applications

Application launchers are intentionally isolated in `binds/applications.kdl`. Chrome, Firefox, terminal, file-manager and other launcher choices are personal policy, not Niri window-management policy.

## System and utilities

`binds/system.kdl` contains the existing working audio/media/brightness controls, power profiles, hardware toggles, native Niri screenshots, recording/OCR helpers, clipboard history, Waybar/Mako/wlsunset utilities, lock/suspend and session exit.

## Conflict policy

Upstream Niri defaults are used where they do not break established personal shortcuts.

Known deliberate differences:
- Upstream `Super+C` is center-column; this setup keeps `Super+C` for Waybar and uses `Super+Alt+C` for center-column.
- Upstream `Super+Ctrl+F` expands a column; this setup keeps it for Firefox and uses `Super+Alt+F`.
- Upstream `Super+Shift+V` switches floating/tiling focus; this setup keeps clipboard history there and uses `Super+Space` for floating/tiling focus.
- Upstream `Super+I` and `Super+Shift+I` workspace variants conflict with Whisper; PageUp/PageDown and Ctrl+I/U retain the corresponding Niri workspace functionality.
- `Super+CapsLock` is not used because Niri 26.04 rejected `CapsLock` as an invalid key name in the tested bind syntax.

The result keeps Niri's window model native without sacrificing the already-tested personal workflow.

## Validation

After updating locally:

```sh
niri validate -c ~/.config/niri/config.kdl
```

When running inside Niri, the configuration can be reloaded with:

```sh
niri msg action load-config-file
```
