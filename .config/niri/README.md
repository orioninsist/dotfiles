# Niri keyboard shortcuts

This file documents the keyboard workflow used by `.config/niri/config.kdl`.

## Table of contents

- [Core](#core)
- [Window navigation](#window-navigation)
- [Window movement and layout](#window-movement-and-layout)
- [Workspaces](#workspaces)
- [Applications](#applications)
- [Capture and recording](#capture-and-recording)
- [Clipboard notifications and utilities](#clipboard-notifications-and-utilities)
- [Audio media brightness and power](#audio-media-brightness-and-power)
- [Session controls](#session-controls)
- [Sway compatibility notes](#sway-compatibility-notes)

## Core

| Shortcut | Action |
|---|---|
| `Super+Enter` | Open Foot |
| `Super+D` | Open wmenu |
| `Super+Shift+Q` | Close focused window |
| `Super+Ctrl+Space` | Switch US/TR keyboard layout |

## Window navigation

| Shortcut | Action |
|---|---|
| `Super+H / Left` | Focus left column |
| `Super+J / Down` | Focus window down |
| `Super+K / Up` | Focus window up |
| `Super+L / Right` | Focus right column |

## Window movement and layout

| Shortcut | Action |
|---|---|
| `Super+Shift+H / Left` | Move column left |
| `Super+Shift+J / Down` | Move window down |
| `Super+Shift+K / Up` | Move window up |
| `Super+Shift+L / Right` | Move column right |
| `Super+R` | Cycle preset column widths |
| `Super+-` | Decrease column width |
| `Super+=` | Increase column width |
| `Super+[` | Consume/expel window left |
| `Super+]` | Consume/expel window right |
| `Super+W` | Toggle tabbed column display |
| `Super+F` | Fullscreen |
| `Super+Shift+Space` | Toggle floating |
| `Super+Space` | Switch focus between floating and tiling |

## Workspaces

| Shortcut | Action |
|---|---|
| `Super+1..9` | Focus workspace 1..9 |
| `Super+0` | Focus workspace 10 |
| `Super+Shift+1..9` | Move column to workspace 1..9 |
| `Super+Shift+0` | Move column to workspace 10 |
| `Super+Tab` | Focus previous workspace |

Workspace placement:
- HDMI-A-1: workspaces 1-5
- eDP-1: workspaces 6-10

## Applications

| Shortcut | Action |
|---|---|
| `Super+Ctrl+Enter` | Alacritty |
| `Super+Y` | Yazi in Kitty |
| `Super+Ctrl+B` | Chrome |
| `Super+Ctrl+Shift+B` | Brave |
| `Super+Ctrl+M` | Microsoft Edge |
| `Super+Ctrl+Shift+Y` | Yandex Browser |
| `Super+Ctrl+F` | Firefox |
| `Super+Ctrl+Shift+F` | Firefox Developer Edition |
| `Super+Ctrl+T` | Tor Browser |
| `Super+Ctrl+Shift+M` | Mullvad Browser |
| `Super+Ctrl+Y` | Nautilus |
| `Super+F10` | Snapshot |
| `Super+P` | Flameshot GUI |

## Capture and recording

| Shortcut | Action |
|---|---|
| `Print` | Niri native screenshot |
| `Super+Print` | Niri native screen screenshot |
| `Super+Ctrl+Print` | Niri native window screenshot |
| `Super+Ctrl+1` | Record display 1 |
| `Super+Ctrl+2` | Record display 2 |
| `Super+Ctrl+3` | Record display 3 |
| `Super+Ctrl+4` | Camera recording |
| `Super+Ctrl+5` | Screen + camera recording |
| `Super+Ctrl+Shift+Print` | OCR |

## Clipboard notifications and utilities

| Shortcut | Action |
|---|---|
| `Super+Shift+V` | Clipboard history |
| `Super+C` | Toggle Waybar visibility |
| `Super+N` | Toggle Mako |
| `Super+Shift+N` | Toggle wlsunset/night light |
| `Super+Ctrl+N` | Notification history |
| `Super+Ctrl+E` | Emoji picker |
| `Super+I` | Whisper typing |
| `Super+Shift+I` | Whisper typing in English |
| `Super+Ctrl+P` | Wayland color picker |

## Audio media brightness and power

| Shortcut | Action |
|---|---|
| `XF86AudioMute` | Toggle mute |
| `XF86AudioLowerVolume` | Volume -5% |
| `XF86AudioRaiseVolume` | Volume +5% |
| `XF86AudioPlay/Pause` | Play/pause |
| `XF86AudioPrev/Next/Stop` | Media controls |
| `XF86MonBrightnessDown/Up` | Brightness -/+ 5% |
| `Super+F1` | Performance profile |
| `Super+F2` | Balanced profile |
| `Super+F3` | Power saver profile |
| `Super+T` | Bluetooth toggle |
| `Super+F4` | Audio output toggle |
| `Super+F5` | Microphone toggle |
| `Super+F6` | Camera toggle |

## Session controls

| Shortcut | Action |
|---|---|
| `Super+Shift+S` | Lock, then suspend |
| `Super+Shift+Escape` | Quit Niri with native confirmation |

## Sway compatibility notes

The Niri configuration keeps the same personal shortcuts where they are compositor-independent and do not collide with Niri-native window management.

Not copied from Sway on purpose:
- `Super+Shift+A`, `Super+Shift+T`, `Super+Shift+D`: Sway display-mode scripts depend on Sway-specific output control.
- Sway screenshot scripts: Niri uses its own native screenshot actions.
- `Super+F11`: opens Sway-specific help.
- Sway layout-only bindings such as split/stacking/container hierarchy/scratchpad are not mapped directly because Niri has a different window model.

The goal is consistent muscle memory without forcing Sway's window model onto Niri.

Super+CapsLock is intentionally not configured: Niri 26.04 rejects CapsLock as an invalid key name in this bind syntax, so the valid Super+Tab previous-workspace binding remains the safe equivalent.
