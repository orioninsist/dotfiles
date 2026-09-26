# Qt KDE Applications

## Rule

KDE Frameworks / Qt applications inside the Niri Wayland session use the Qt KDE wrapper.

Launcher:

```bash
qt-kde-launch <application>
```

Examples:

- dolphin
- okular
- ark
- gwenview
- kate
- konsole
- spectacle

## Do not use wrapper for

- GTK applications
- Electron applications
- browsers
- VS Code

## Reason

Niri is not a KDE Plasma session. KDE Qt applications need explicit Qt/KDE environment handling for Breeze theme and KDE integration.

The wrapper is the single place for:

- QT_STYLE_OVERRIDE
- Qt/KDE theme integration
- KDE application launch environment

New KDE applications should follow the same pattern instead of adding individual fixes.
