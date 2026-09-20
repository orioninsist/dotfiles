# Niri configuration

Modular Niri configuration for the daily Wayland session.

## Table of contents

- [Structure](#structure)
- [Shortcut reference](#shortcut-reference)
- [Daily workflow](#daily-workflow)
- [Professional productivity patterns](#professional-productivity-patterns)
- [Personal applications](#personal-applications)
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

## First-time daily use: build muscle memory first

If this is your first time using Niri, do **not** try to memorize every shortcut. Start with the small set below and use only these for the first few days.

### The 8 shortcuts to learn first

| Shortcut | What it means in daily use |
|---|---|
| `Super+1` | Web / Research / AI |
| `Super+2` | Terminal / Operations |
| `Super+3` | Development |
| `Super+4` | Work / Office |
| `Super+5` | Communication / Business |
| `Super+6` | Creative / Design |
| `Super+7` | Media / Content |
| `Super+8` | System / VM / Device |
| `Super+9` | Finance / Monitoring |
| `Super+0` | Free / temporary workspace; no automatic routing |
| `Super+H / Super+L` | Move focus to the column on the left/right |
| `Super+J / Super+K` | Move focus down/up **only when multiple windows are stacked in the same column** |
| `Super+R` | Change the active column width |
| `Super+M` | Make the active window large while staying in the Niri flow |
| `Super+O` | Open Overview when you feel lost |

### Important: why J/K may appear to do nothing

Niri is column-based. If Chrome and another browser window are each in their own column, the layout looks like this:

```text
[ Chrome ] [ Mullvad ] [ Firefox ]
```

In that case:

- `Super+H` goes to the column on the left.
- `Super+L` goes to the column on the right.
- `Super+J` and `Super+K` do nothing because there is no window above or below the focused window.

`Super+J / Super+K` become useful only after two or more windows are placed inside the same column:

```text
[ Chrome ] [ Terminal ]
           [ Logs     ]
```

Now, while the second column is focused:

- `Super+J` moves from Terminal to Logs.
- `Super+K` moves from Logs back to Terminal.

So for a new user, remember this simple rule:

```text
H / L = left / right between columns
J / K = up / down inside one stacked column
```

### First 30-minute practice

1. Press `Super+1` and open two browser windows. Use `Super+H` and `Super+L` until left/right navigation feels automatic.
2. Press `Super+R` a few times. Notice how the focused column cycles through useful widths.
3. Press `Super+M` to make the focused window large without leaving the normal Niri workflow.
4. Press `Super+F` once to see true fullscreen, then press it again to return. Use fullscreen only when you really want one application to take over the screen.
5. Press `Super+O` whenever you lose track of where a window is.
6. Build the core reflex first: Web = 1, Terminal = 2, Development = 3. Then learn the secondary domains: Office = 4, Communication = 5, Creative = 6, Media = 7, System/VM = 8, Finance = 9. Keep 0 free for temporary work.
7. Only after H/L feels natural, create a multi-window column with `Super+,` (consume into column) and practice `Super+J / Super+K`.
8. Use `Super+.` to expel a window from that column again.

### Daily mental model

Do not think of Niri as “a screen split into boxes.” Think of each workspace as a horizontal strip of columns:

```text
... [ docs ] [ editor ] [ terminal ] [ browser ] [ chat ] ...
                    <---- H / L ---->
```

A column can contain one window, or several windows stacked vertically:

```text
[ editor ] [ terminal ]
           [ logs     ]
           [ tests    ]
               ^
              J/K
```

The goal is to stop arranging every window manually. Use:

- workspace numbers to choose the kind of work;
- H/L to move through that work horizontally;
- J/K only inside stacked columns;
- R to normalize width;
- O to recover visually when the session gets busy.

Once these are automatic, then learn consume/expel, monitor movement, first/last-column jumps and the rest of the reference below.

## Shortcut reference

### Window management

| Shortcut | Action |
|---|---|
| `Super+Shift+/` | Hotkey overlay |
| `Super+O` | Overview |
| `Super+Shift+Q` | Close window |
| `Super+H/J/K/L` or arrows | Focus columns/windows |
| `Super+Shift+H/J/K/L` or arrows | Move columns/windows; retained muscle memory |
| `Super+Ctrl+H/J/K/L` or arrows | Niri upstream-style move columns/windows |
| `Super+Home/End` | Focus first/last column |
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

### Workspaces

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

Workspace placement:
- HDMI-A-1: 1-5
- eDP-1: 6-10

The physical output preference is separate from task routing. Applications are routed by task domain, and a column can still be moved to another workspace or monitor whenever the current task needs it.

### Stable workspace map

| Key | Workspace | Purpose | Typical applications |
|---|---:|---|---|
| `Super+1` | 1 | Web / Research / AI | Chrome, Firefox, Brave, Edge, Tor, Mullvad, ChatGPT, Gemini, Grok, NotebookLM, GitHub, Stack Overflow, Reddit, Quora, Pinterest, Google Translate, Knowledge, Colab |
| `Super+2` | 2 | Terminal / Operations | Foot, Alacritty, Kitty and shell-driven operations |
| `Super+3` | 3 | Development | VS Code, Zed, Antigravity, JetBrains IDEs and development tools |
| `Super+4` | 4 | Work / Office | Drive, Docs, Sheets, Slides, Calendar, Contacts, Keep, Tasks, Forms, Google Password Manager, Google Photos, Google Vids, calibre |
| `Super+5` | 5 | Communication / Business | Element, Signal, Messages, Facebook, Instagram, Meta Business Suite, Google AdSense |
| `Super+6` | 6 | Creative / Design | GIMP, Inkscape, Krita, Adobe Express, Firefly, Excalidraw |
| `Super+7` | 7 | Media / Content | OBS, mpv, Spotify, HandBrake, Folo, NewsFlash, YouTube, YouTube Music, Google News |
| `Super+8` | 8 | System / VM / Device | virt-manager, scrcpy, pavucontrol, Easy Effects |
| `Super+9` | 9 | Finance / Monitoring | TradingView, Google Analytics |
| `Super+0` | 10 | Free / Temporary | No automatic routing; use for ad-hoc work |

The first three are the primary muscle-memory anchors: **1 = Web, 2 = Terminal, 3 = Code**. Workspaces 4-9 are stable secondary domains. Workspace 10 is deliberately kept unassigned so temporary work never forces a permanent category change.

### System and utilities

| Shortcut | Action |
|---|---|
| `Super+Ctrl+Space` | Switch US/TR keyboard layout |
| `Super+Shift+V` | Clipboard history |
| `Super+C` | Toggle Waybar |
| `Super+N` | Toggle Mako |
| `Super+Shift+N` | Toggle wlsunset / night light |
| `Super+Ctrl+N` | Notification history |
| `Super+Ctrl+E` | Emoji picker |
| `Super+I` | Whisper typing |
| `Super+Shift+I` | Whisper typing in English |
| `Super+Ctrl+P` | Color picker |
| `Print` | Screenshot |
| `Super+Print` | Screenshot screen |
| `Super+Ctrl+Print` | Screenshot window |
| `Super+Ctrl+1..5` | Recording helpers |
| `Super+Shift+S` | Lock, then suspend |
| `Super+Shift+Escape` | Quit Niri |
| `Super+Shift+P` | Power off monitors |

## Daily workflow

The most productive way to use Niri is not to imitate a classic tiling manager. Treat each workspace as a horizontal strip of related columns. Keep only the current task visible, then move left/right through context instead of constantly resizing every window.

A practical daily pattern with the current setup:

1. **Start from Overview** with `Super+O`. Use it as the visual map of the session instead of hunting through windows one by one.
2. **Use workspaces by activity**, not by application count. The stable task map is: 1 Web/Research/AI, 2 Terminal/Ops, 3 Development, 4 Work/Office, 5 Communication/Business, 6 Creative/Design, 7 Media/Content, 8 System/VM/Device, 9 Finance/Monitoring, and 10 (accessed with `Super+0`) Free/Temporary. Workspace 10 intentionally has no automatic application routing.
3. **Navigate with H/J/K/L**. Horizontal H/L changes columns; J/K moves inside a multi-window column. This matches Niri's data model and keeps navigation predictable.
4. **Build columns deliberately**. Use `Super+[` / `Super+]` or `Super+,` / `Super+.` to combine related windows. For example, keep a terminal and its monitoring/log window in one vertical column instead of consuming two horizontal positions.
5. **Size by role, not by pixel chasing**. `Super+R` cycles useful preset widths. Use `Super+-/+` only for exceptions. This is faster than continually fine-tuning every window.
6. **Use fullscreen only for real focus** with `Super+F`. For a large working window that should still remain in the Niri flow, `Super+M` or `Super+Alt+F` is usually more useful than fullscreen.
7. **Use `Super+Tab` for context switching** between the current and previous workspace. It is ideal for repeatedly jumping between code and browser/research without remembering workspace numbers.
8. **Use the second monitor as capacity, not duplication**. Move an entire active column with `Super+Ctrl+Shift+H/J/K/L`; keep the main editing column on one display and reference/monitoring material on the other.

## Professional productivity patterns

### Coding + research

Example: VS Code/Zed/JetBrains on workspace 3, Chrome/Firefox/research on workspace 1, and terminals on workspace 2. Office work belongs on 4, communication on 5, creative tools on 6, media/content on 7, system/VM/device tools on 8, and finance/monitoring on 9.

Use `Super+Tab` to jump between development and the last research workspace. When documentation needs to stay visible, move the browser column to the other monitor with `Super+Ctrl+Shift+H/L`. Keep terminal output grouped vertically with another terminal using consume/expel rather than opening many narrow columns.

A useful rhythm is:

`Super+O` → choose context → `H/L` to move between columns → `J/K` within a stacked column → `Super+R` to normalize width.

### Browser-heavy research

For many Chrome/Firefox windows, avoid maximizing everything. Give the active article or ChatGPT/research page a larger column with `Super+R` or `Super+Alt+F`, keep supporting pages in neighboring columns, and use `Super+Home/End` to jump to the edges of a long research strip.

If several pages belong to one subtopic, combine them into one column and use J/K vertically. This prevents a 10-window research session from becoming a 10-column horizontal hunt.

### Terminal and operations work

Workspace 2 is a good place for shells, logs and device tools. A productive Niri layout is one main shell column plus a stacked monitoring column. Use `Super+Ctrl+Home/End` when you want a permanent “anchor” column at the beginning or end of the workspace.

For remote desktop, KVM or applications that capture shortcuts, `Super+Escape` is the escape hatch for keyboard-shortcut inhibition.

### Writing / productivity

Keep the main editor or document in the center and reference material adjacent. `Super+Alt+C` recenters the working column after moving through references. `Super+Alt+Ctrl+C` is useful after opening several supporting columns and wanting the visible group centered again.

For a distraction-free writing pass, use `Super+F`. When you still need surrounding context, prefer `Super+M` or `Super+Alt+F`.

### Two-monitor workflow

The output preference places workspaces 1-5 on HDMI-A-1 and 6-10 on eDP-1 by default. This is only the starting physical placement; the task-domain map above remains the mental model. In daily use, do not think of the monitor split as a hard wall. Niri can move the active column between monitors with `Super+Ctrl+Shift+H/J/K/L`.

A strong two-monitor pattern is:
- primary monitor: the thing being edited or controlled;
- secondary monitor: browser/reference, logs, video, monitoring or communication;
- move columns, not individual windows, when the whole context belongs together.

### Fast recovery when the session feels messy

When too many windows accumulate:

1. `Super+O` to see the whole state.
2. Move unrelated work to its numbered workspace.
3. Group related windows into columns with consume/expel.
4. Normalize widths with `Super+R`.
5. Use `Super+Home/End` to find edge columns quickly.
6. Center the active work with `Super+Alt+C`.

This is usually faster than manually dragging and resizing every window.

## Personal applications

Application launchers are intentionally isolated in `binds/applications.kdl`. Chrome, Firefox, terminals, file manager and other launchers are personal workflow choices, not Niri window-management policy.

The applications referenced by the config follow the stable task-domain map above. Browser/research/AI starts on 1; terminals on 2; development on 3; office on 4; communication/business on 5; creative/design on 6; media/content on 7; system/VM/device tools on 8; and finance/monitoring on 9.

Helper applications such as Nautilus are intentionally not forced to a permanent workspace because they are useful inside many different task contexts. Workspace 10 is also intentionally excluded from automatic routing.

The goal is not to memorize an application shortcut for every task. Use application launchers to start work, then rely on Niri's window/workspace navigation for the rest of the session.

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

When running inside Niri:

```sh
niri msg action load-config-file
```
