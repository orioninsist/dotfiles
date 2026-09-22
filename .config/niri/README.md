# Niri configuration

Modular Niri configuration for the daily Wayland session.

## Structure

| File | Responsibility |
|---|---|
| `config.kdl` | Input, outputs, layout, startup, workspaces, window rules and includes |
| `binds/window-management.kdl` | Niri-native window, column, monitor and layout actions |
| `binds/workspaces.kdl` | Workspace navigation, movement and wheel navigation |
| `binds/system.kdl` | Audio, media, brightness, capture, hardware, notifications and session |
| `binds/applications.kdl` | Personal application launchers only |

Niri 26.04 supports `include`, so the main config stays small while each binding domain remains independently maintainable.

## Workspace / tag map

The task map is stable and intended for muscle memory:

| Key | Workspace | Purpose | Typical applications |
|---|---:|---|---|
| `Super+1` | 1 | Web / Research / AI / Files | Chrome, Firefox, Brave, Edge, Tor, Mullvad, ChatGPT, Gemini, Grok, NotebookLM, GitHub, Stack Overflow, Reddit, Quora, Pinterest, Translate, Colab, Nautilus |
| `Super+2` | 2 | Terminal / Operations | Foot, Alacritty, Kitty, shell-driven operations |
| `Super+3` | 3 | Development | VS Code, Zed, Antigravity, JetBrains IDEs and development tools |
| `Super+4` | 4 | Work / Office | Drive, Docs, Sheets, Slides, Calendar, Contacts, Keep, Tasks, Forms, Password Manager, Photos, Vids, calibre |
| `Super+5` | 5 | Communication / Business | Element, Signal, Messages, Facebook, Instagram, Meta Business Suite, Google AdSense |
| `Super+6` | 6 | Creative / Design / Media | GIMP, Inkscape, Krita, Adobe Express, Firefly, Excalidraw, YouTube, YouTube Music, Mullvad Browser, Spotify |
| `Super+7` | 7 | Productivity / Content | Knowledge Productivity, Knowledge webapp, OBS, mpv, HandBrake, Folo, NewsFlash, Google News |
| `Super+8` | 8 | System / VM / Device | virt-manager, scrcpy, pavucontrol, Easy Effects |
| `Super+9` | 9 | Finance / Monitoring | TradingView, Google Analytics |
| `Super+0` | 10 | Free / Temporary | Espanso Manager plus ad-hoc temporary work |

Physical placement:
- Workspaces 1-5 prefer `HDMI-A-1` (ASUS).
- Workspaces 6-10 prefer `eDP-1` (ThinkPad).
- This is only a default placement; columns can still be moved between monitors.

## Complete shortcut reference

### Window management

| Shortcut | Action |
|---|---|
| `Super+Shift+/` | Show Niri hotkey overlay |
| `Super+O` | Toggle Overview |
| `Super+Shift+Q` | Close focused window |
| `Super+H` / `Super+Left` | Focus column left |
| `Super+L` / `Super+Right` | Focus column right |
| `Super+J` / `Super+Down` | Focus window down inside a stacked column |
| `Super+K` / `Super+Up` | Focus window up inside a stacked column |
| `Super+Shift+H` / `Super+Shift+Left` | Move column left |
| `Super+Shift+L` / `Super+Shift+Right` | Move column right |
| `Super+Shift+J` / `Super+Shift+Down` | Move window down |
| `Super+Shift+K` / `Super+Shift+Up` | Move window up |
| `Super+Ctrl+H/J/K/L` or arrows | Same move-column/window actions using Niri upstream Ctrl style |
| `Super+Home` | Focus first column |
| `Super+End` | Focus last column |
| `Super+Ctrl+Home` | Move column to first |
| `Super+Ctrl+End` | Move column to last |
| `Super+Ctrl+Shift+H/J/K/L` or arrows | Move active column to monitor left/down/up/right |
| `Super+[` | Consume/expel window left |
| `Super+]` | Consume/expel window right |
| `Super+,` | Consume window into current column |
| `Super+.` | Expel window from current column |
| `Super+R` | Next preset column width |
| `Super+Shift+R` | Previous preset column width |
| `Super+Ctrl+Shift+R` | Next preset window height |
| `Super+Ctrl+R` | Reset window height |
| `Super+-` | Decrease column width by 10% |
| `Super++` | Increase column width by 10% |
| `Super+Shift+-` | Decrease window height by 10% |
| `Super+Shift++` | Increase window height by 10% |
| `Super+F` | Fullscreen focused window |
| `Super+M` | Maximize focused window to screen edges |
| `Super+Alt+F` | Expand column to available width |
| `Super+Alt+C` | Center focused column |
| `Super+Alt+Ctrl+C` | Center visible columns |
| `Super+V` | Toggle floating for focused window |
| `Super+Space` | Switch focus between floating and tiling |
| `Super+W` | Toggle tabbed column display |
| `Super+Escape` | Toggle keyboard-shortcut inhibition escape hatch |

### Workspace navigation and movement

| Shortcut | Action |
|---|---|
| `Super+1..9` | Focus workspaces 1..9 |
| `Super+0` | Focus workspace 10 |
| `Super+Shift+1..9` | Move active column to workspaces 1..9 |
| `Super+Shift+0` | Move active column to workspace 10 |
| `Super+Tab` | Focus previous workspace |
| `Super+CapsLock` | Focus previous workspace |
| `Super+PageDown` | Workspace down |
| `Super+PageUp` | Workspace up |
| `Super+U` | Workspace down |
| `Super+Ctrl+PageDown` | Move column to workspace down |
| `Super+Ctrl+PageUp` | Move column to workspace up |
| `Super+Ctrl+U` | Move column to workspace down |
| `Super+Ctrl+I` | Move column to workspace up |
| `Super+Shift+PageDown` | Reorder current workspace down |
| `Super+Shift+PageUp` | Reorder current workspace up |
| `Super+Shift+U` | Reorder current workspace down |
| `Super+WheelDown/Up` | Focus workspace down/up |
| `Super+Ctrl+WheelDown/Up` | Move column to workspace down/up |
| `Super+WheelRight/Left` | Focus column right/left |
| `Super+Ctrl+WheelRight/Left` | Move column right/left |
| `Super+Shift+WheelDown/Up` | Focus column right/left |
| `Super+Ctrl+Shift+WheelDown/Up` | Move column right/left |

### Applications

| Shortcut | Action |
|---|---|
| `Super+Enter` | Foot terminal |
| `Super+D` | wmenu-run application launcher |
| `Super+Ctrl+Enter` | Alacritty |
| `Super+Y` | Kitty running Yazi |
| `Super+Ctrl+B` | Google Chrome |
| `Super+Ctrl+Shift+B` | Brave |
| `Super+Ctrl+M` | Microsoft Edge |
| `Super+Ctrl+Shift+Y` | Yandex Browser |
| `Super+Ctrl+F` | Firefox |
| `Super+Ctrl+Shift+F` | Firefox Developer Edition |
| `Super+Ctrl+T` | Tor Browser |
| `Super+Ctrl+Shift+M` | Mullvad Browser |
| `Super+Ctrl+Y` | Nautilus |
| `Super+F8` | Focus workspace 7 and launch Knowledge Productivity |
| `Super+F9` | Focus workspace 10 and launch Espanso Manager |
| `Super+P` | Flameshot GUI |

### Display, power profile and hardware

| Shortcut | Action |
|---|---|
| `Super+F1` | Cycle power profile: Performance → Balanced → Power Saver |
| `Super+T` | Toggle Bluetooth |
| `Super+F4` | Toggle audio output |
| `Super+F5` | Toggle microphone |
| `Super+F6` | Toggle camera |
| `Super+Shift+A` | ASUS-only display mode |
| `Super+Shift+T` | ThinkPad-only display mode |
| `Super+Shift+D` | Dual-monitor mode |
| `XF86AudioMute` | Mute/unmute default audio sink |
| `XF86AudioLowerVolume` | Volume -5% |
| `XF86AudioRaiseVolume` | Volume +5% |
| `XF86AudioPlay/Pause` | Media play/pause |
| `XF86AudioPrev` | Previous media |
| `XF86AudioNext` | Next media |
| `XF86AudioStop` | Stop media |
| `XF86MonBrightnessDown` | Brightness -5% |
| `XF86MonBrightnessUp` | Brightness +5% |

### Screenshot, recording and OCR

| Shortcut | Action |
|---|---|
| `Print` | Interactive Niri screenshot |
| `Super+Print` | Screenshot current screen/output |
| `Super+Ctrl+Print` | Screenshot focused window |
| `Super+Ctrl+Shift+Print` | OCR capture via `~/.config/wayland/scripts/ocr` |
| `Super+Ctrl+1` | Screen recording helper mode 1 |
| `Super+Ctrl+2` | Screen recording helper mode 2 |
| `Super+Ctrl+3` | Screen recording helper mode 3 |
| `Super+Ctrl+4` | Camera recording |
| `Super+Ctrl+5` | Screen + camera recording |

### Productivity and utilities

| Shortcut | Action |
|---|---|
| `Super+Ctrl+Space` | Switch keyboard layout US/TR |
| `Super+I` | Whisper typing |
| `Super+Shift+I` | Whisper typing in English |
| `Super+Ctrl+P` | Color picker |
| `Super+Shift+V` | Clipboard history |
| `Super+N` | Toggle Mako |
| `Super+Shift+N` | Toggle wlsunset / night light |
| `Super+Ctrl+N` | Notification history |
| `Super+Ctrl+E` | Emoji picker |
| `Super+Shift+C` | Reload Niri config |
| `Super+F11` | Open this README in Glow inside Foot |

### Session

| Shortcut | Action |
|---|---|
| `Super+Shift+S` | Lock with swaylock, then suspend |
| `Super+Shift+P` | Power off monitors |
| `Super+Shift+Escape` | Quit Niri |
| `Ctrl+Alt+Delete` | Quit Niri |

## Daily mental model

Niri is column-based. Think of every workspace as a horizontal strip:

```text
... [ docs ] [ editor ] [ terminal ] [ browser ] [ chat ] ...
                    <---- H / L ---->
```

A column can contain several vertically stacked windows:

```text
[ editor ] [ terminal ]
           [ logs     ]
           [ tests    ]
               ^
              J/K
```

Simple rule:

```text
H / L = move focus left / right between columns
J / K = move focus up / down inside one stacked column
```

If J/K appears to do nothing, the focused column probably contains only one window.

Useful recovery flow when a session gets messy:

1. `Super+O` to see everything.
2. Move unrelated work to its numbered workspace.
3. Group related windows with `Super+,` / `Super+.` or `Super+[` / `Super+]`.
4. Normalize width with `Super+R`.
5. Use `Super+Home/End` to reach the edges quickly.
6. Recenter with `Super+Alt+C`.

## Conflict policy

Upstream Niri defaults are used where they do not break established personal shortcuts.

Deliberate differences:
- `Super+C` is free; `Super+Alt+C` remains the center-column shortcut.
- Upstream `Super+Ctrl+F` expands a column; this setup keeps it for Firefox and uses `Super+Alt+F`.
- Upstream `Super+Shift+V` switches floating/tiling focus; this setup keeps clipboard history there and uses `Super+Space`.
- `Super+I` and `Super+Shift+I` are reserved for Whisper.
- `Super+CapsLock` uses the accepted `Caps_Lock` key name in the bind file.

## Validation

After pulling locally:

```sh
niri validate -c ~/.config/niri/config.kdl
```

To reload while Niri is running:

```sh
niri msg action load-config-file
```


