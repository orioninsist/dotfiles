# Sway Keyboard Reference

Bu dizin artık tek bir güncel belge içerir. Amaç, Sway içindeki bütün klavye kısayollarını tek ekranda ve Glow ile okunabilir bir Markdown tablosunda tutmaktır.

> Kaynak: `~/.config/sway/config` ve include edilen Sway `.conf` dosyaları.
>
> `Super` = `Mod4`
>
> Kural: Window Management tarafında script yoktur; native Sway komutları kullanılır.

## İçindekiler

- [Core](#core)
- [Window Management](#window-management)
- [Workspaces](#workspaces)
- [Applications and Utilities](#applications-and-utilities)
- [System Controls](#system-controls)
- [Capture and Recording](#capture-and-recording)
- [Input](#input)
- [Session](#session)
- [Bar](#bar)

## Core

| Shortcut | Action | Source |
|---|---|---|
| `Super + Return` | Foot terminal | `config` |
| `Super + Shift + Q` | Focused window close | `config` |
| `Super + Shift + C` | Reload Sway config | `config` |

## Window Management

| Shortcut | Action | Source |
|---|---|---|
| `Super + H/J/K/L` | Focus left/down/up/right | `window-management.conf` |
| `Super + ←/↓/↑/→` | Focus left/down/up/right | `window-management.conf` |
| `Super + Shift + H/J/K/L` | Move container left/down/up/right | `window-management.conf` |
| `Super + Shift + ←/↓/↑/→` | Move container left/down/up/right | `window-management.conf` |
| `Super + B` | Horizontal split | `window-management.conf` |
| `Super + V` | Vertical split | `window-management.conf` |
| `Super + S` | Stacking layout | `window-management.conf` |
| `Super + W` | Tabbed layout | `window-management.conf` |
| `Super + E` | Toggle split layout | `window-management.conf` |
| `Super + F` | Fullscreen | `window-management.conf` |
| `Super + Shift + Space` | Toggle floating | `window-management.conf` |
| `Super + Space` | Toggle focus between tiling/floating | `window-management.conf` |
| `Super + A` | Focus parent container | `window-management.conf` |
| `Super + Shift + -` | Move focused container to scratchpad | `window-management.conf` |
| `Super + -` | Show/cycle scratchpad | `window-management.conf` |
| `Super + R` | Enter resize mode | `window-management.conf` |
| `H/J/K/L` | Resize width/height while in resize mode | `window-management.conf` |
| `←/↓/↑/→` | Resize width/height while in resize mode | `window-management.conf` |
| `Return / Escape` | Leave resize mode | `window-management.conf` |

## Workspaces

| Shortcut | Action | Source |
|---|---|---|
| `Super + 1..0` | Switch to workspace 1..10 | `workspaces.conf` |
| `Super + Shift + 1..0` | Move focused container to workspace 1..10 | `workspaces.conf` |
| `Super + Tab` | Next workspace on current output | `workspaces.conf` |
| `Super + Caps Lock` | Back-and-forth workspace | `workspaces.conf` |

## Applications and Utilities

| Shortcut | Action | Source |
|---|---|---|
| `Super + D` | Application launcher | `shortcuts.conf` |
| `Super + G` | Clipboard history in Foot | `shortcuts.conf` |
| `Super + Shift + V` | Clipboard history | `shortcuts.conf` |
| `Super + Y` | Yazi in Kitty | `shortcuts.conf` |
| `Super + Shift + Return` | Foot terminal | `shortcuts.conf` |
| `Super + Ctrl + Return` | Alacritty | `shortcuts.conf` |
| `Super + F10` | Snapshot | `shortcuts.conf` |
| `Super + P` | Flameshot GUI | `shortcuts.conf` |
| `Super + Shift + A` | ASUS display mode | `shortcuts.conf` |
| `Super + Shift + T` | ThinkPad display mode | `shortcuts.conf` |
| `Super + Shift + D` | Dual display mode | `shortcuts.conf` |
| `Super + I` | Voice typing | `shortcuts.conf` |
| `Super + Shift + I` | English voice typing | `shortcuts.conf` |
| `Super + F11` | Sway help | `shortcuts.conf` |
| `Super + Ctrl + P` | Wayland color picker | `shortcuts.conf` |
| `Super + Ctrl + N` | Notification history | `shortcuts.conf` |
| `Super + Ctrl + E` | Emoji picker | `shortcuts.conf` |

## System Controls

| Shortcut | Action | Source |
|---|---|---|
| `XF86AudioMute` | Toggle mute | `system-controls.conf` |
| `XF86AudioLowerVolume` | Volume down | `system-controls.conf` |
| `XF86AudioRaiseVolume` | Volume up | `system-controls.conf` |
| `XF86AudioPlay / Pause` | Play/pause | `system-controls.conf` |
| `XF86AudioPrev` | Previous track | `system-controls.conf` |
| `XF86AudioNext` | Next track | `system-controls.conf` |
| `XF86AudioStop` | Stop playback | `system-controls.conf` |
| `XF86MonBrightnessDown` | Brightness down | `system-controls.conf` |
| `XF86MonBrightnessUp` | Brightness up | `system-controls.conf` |
| `Super + F1` | Performance power profile | `system-controls.conf` |
| `Super + F2` | Balanced power profile | `system-controls.conf` |
| `Super + F3` | Power-saver profile | `system-controls.conf` |
| `Super + T` | Bluetooth toggle | `system-controls.conf` |
| `Super + F4` | Audio output toggle | `system-controls.conf` |
| `Super + F5` | Microphone toggle | `system-controls.conf` |
| `Super + F6` | Camera toggle | `system-controls.conf` |

## Capture and Recording

| Shortcut | Action | Source |
|---|---|---|
| `Print` | Area screenshot | `capture.conf` |
| `Super + Print` | ThinkPad screenshot | `capture.conf` |
| `Super + Shift + Print` | ASUS screenshot | `capture.conf` |
| `Super + Ctrl + Print` | Area screenshot to clipboard | `capture.conf` |
| `Super + Ctrl + 1` | Screen recording mode 1 | `capture.conf` |
| `Super + Ctrl + 2` | Screen recording mode 2 | `capture.conf` |
| `Super + Ctrl + 3` | Screen recording mode 3 | `capture.conf` |
| `Super + Ctrl + 4` | Camera recording | `capture.conf` |
| `Super + Ctrl + 5` | Screen + camera recording | `capture.conf` |
| `Super + Ctrl + Shift + Print` | OCR | `capture.conf` |

## Input

| Shortcut | Action | Source |
|---|---|---|
| `Super + Ctrl + Space` | Toggle keyboard layout (US/TR) | `input.conf` |

## Session

| Shortcut | Action | Source |
|---|---|---|
| `Super + Shift + S` | Lock and suspend | `session.conf` |
| `Super + Shift + Escape` | Exit Sway with confirmation | `session.conf` |
| `Super + Shift + N` | Night light toggle | `session.conf` |
| `Super + N` | Notifications toggle | `session.conf` |

## Bar

| Shortcut | Action | Source |
|---|---|---|
| `Super + C` | Toggle Waybar visibility | `bar.conf` |

## Glow

```bash
glow -p ~/.config/sway/docs/README.md
```

Bu belge mevcut Sway config'iyle birlikte güncel tutulmalıdır. Bir binding değiştiğinde yalnızca bu tek dosya güncellenir.
