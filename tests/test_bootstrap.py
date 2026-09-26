from pathlib import Path
import re
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def test_manifest_exists():
    assert (ROOT / "install/manifest.tsv").is_file()


def test_required_repo_paths():
    for p in [".config/niri", ".config/systemd/user", ".config/wayland/scripts"]:
        assert (ROOT / p).exists(), p


def test_no_broken_repo_symlinks():
    broken = [p for p in ROOT.rglob("*") if p.is_symlink() and not p.exists()]
    assert not broken, broken


def test_core_commands_after_install():
    required = [
        "git", "python3", "niri", "wpctl", "wl-copy", "wl-paste",
        "fzf", "rg", "kitty", "mako", "makoctl", "grim", "slurp",
        "tesseract", "notify-send", "dolphin",
    ]
    missing = [x for x in required if shutil.which(x) is None]
    assert not missing, missing


def test_user_config_links_after_deploy():
    home = Path.home()
    for name in ["niri", "systemd", "wayland"]:
        p = home / ".config" / name
        assert p.is_symlink(), p
        assert p.resolve() == (ROOT / ".config" / name).resolve()


def test_niri_config_validates():
    result = subprocess.run(
        ["niri", "validate"],
        cwd=ROOT,
        capture_output=True,
        text=True,
    )
    assert result.returncode == 0, result.stdout + result.stderr


def test_installer_uses_only_dnf_package_manager():
    offenders = []
    for p in (ROOT / "install").glob("*.sh"):
        if p.name.startswith("audit-"):
            continue
        text = p.read_text(errors="ignore")
        for line_no, line in enumerate(text.splitlines(), 1):
            stripped = line.strip()
            if not stripped or stripped.startswith("#"):
                continue
            if re.search(r"(^|[;&|]\\s*)(pacman|yay|paru|apt-get|apt)(\\s|$)", stripped):
                offenders.append(f"{p.name}:{line_no}: {stripped}")
    assert not offenders, offenders


def test_portable_runtime_paths():
    files = [
        ROOT / ".config/niri/config.kdl",
        ROOT / ".config/niri/binds/applications.kdl",
        ROOT / ".config/kitty/kitty.conf",
        ROOT / ".config/wayland/scripts/fzf-popup",
        ROOT / ".config/wayland/scripts/ocr",
        ROOT / ".config/wayland/scripts/mako-toggle",
        ROOT / ".config/yazi/yazi.toml",
        ROOT / ".config/systemd/user/easyeffects.service",
        ROOT / ".config/systemd/user/cliphist.service",
        ROOT / ".local/share/applications/zellij.desktop",
        ROOT / ".profile",
    ]
    banned = ["/usr/local/bin/", "/home/murat/"]
    failures = {}
    for path in files:
        content = path.read_text(errors="ignore")
        found = [token for token in banned if token in content]
        if found:
            failures[str(path.relative_to(ROOT))] = found
    assert not failures, failures


def test_fzf_app_launcher_uses_cache():
    launcher = (ROOT / ".config/wayland/scripts/app-launcher").read_text()
    assert "orion-launcher" in launcher
    assert "cache_is_stale" in launcher
    assert "path-apps.ignore" in launcher
    assert "fzf --prompt='Run > ' < \"$cache_file\"" in launcher
    assert "QT_QPA_PLATFORMTHEME" in launcher
    assert "KDE_COLOR_SCHEME=CatppuccinMochaMauve" in launcher
    assert "-u CALIBRE_USE_SYSTEM_THEME" in launcher


def test_qt_theme_is_global_not_per_app_wrapper():
    env = (ROOT / ".config/environment.d/20-qt-theme.conf").read_text()
    assert "QT_QPA_PLATFORM=wayland;xcb" in env
    assert "QT_QPA_PLATFORMTHEME=qt6ct" in env
    assert "KDE_COLOR_SCHEME=CatppuccinMochaMauve" in env
    assert "QT_STYLE_OVERRIDE" not in env
    assert "CALIBRE_USE_SYSTEM_THEME" not in env
    assert not (ROOT / ".config/wayland/scripts/qt-kde-launch").exists()
    assert not (ROOT / ".local/bin/qt-kde-launch").exists()

    niri = (ROOT / ".config/niri/config.kdl").read_text()
    assert 'QT_QPA_PLATFORMTHEME "qt6ct"' in niri
    assert 'QT_STYLE_OVERRIDE null' in niri
    assert 'CALIBRE_USE_SYSTEM_THEME null' in niri


def test_calibre_uses_builtin_dark_palette_not_system_theme():
    wrapper = (ROOT / ".local/bin/calibre-kde").read_text()
    assert "exec /usr/bin/calibre" in wrapper
    assert "unset CALIBRE_USE_SYSTEM_THEME" in wrapper
    installer = (ROOT / "install/20-dotfiles.sh").read_text()
    assert "calibre-debug" in installer
    assert "gprefs['color_palette']='dark'" in installer
    assert "gprefs['ui_style']='calibre'" in installer


def test_qt_theme_packages_are_declared():
    manifest = (ROOT / "install/manifest.tsv").read_text(errors="ignore")
    for package in ["qt6ct", "qt5ct", "kvantum", "kvantum-qt5", "kvantum-data"]:
        assert f"dnf\t{package}\t" in manifest


def test_kdeglobals_pins_mocha_breeze_appearance():
    kdeglobals = (ROOT / ".config/kdeglobals").read_text()
    assert "ColorScheme=CatppuccinMochaMauve" in kdeglobals
    assert "Theme=breeze-dark" in kdeglobals
    assert "widgetStyle=Breeze" in kdeglobals

    for name in ["dolphinrc", "gwenviewrc", "arkrc", "okularrc"]:
        rc = (ROOT / ".config" / name).read_text()
        assert "ColorScheme=CatppuccinMochaMauve" in rc


def test_kde_app_desktop_entries_avoid_path_wrapper_recursion():
    for app in ["ark", "gwenview", "okular"]:
        assert not (ROOT / ".local/bin" / app).exists(), app
        assert not (ROOT / ".local/share/applications" / f"org.kde.{app}.desktop").exists(), app


def test_removed_apps_stay_out_of_launcher():
    ignored = (ROOT / ".config/wayland/path-apps.ignore").read_text().splitlines()
    assert "snapshot" in ignored
    assert "snapshot" not in (ROOT / ".config/niri/binds/applications.kdl").read_text()
    assert "\tdnf\tsnapshot\t" not in (ROOT / "install/manifest.tsv").read_text()


def test_niri_portal_backend():
    portal = (ROOT / ".config/xdg-desktop-portal/portals.conf").read_text()
    assert "org.freedesktop.impl.portal.ScreenCast=gnome" in portal
    assert "org.freedesktop.impl.portal.Screenshot=gnome" in portal
    assert "xdg-desktop-portal-wlr" not in portal


def test_niri_referenced_commands_are_declared():
    manifest = (ROOT / "install/manifest.tsv").read_text(errors="ignore")
    rows = [
        line.split("\t")
        for line in manifest.splitlines()
        if line and not line.startswith("#") and len(line.split("\t")) >= 3
    ]
    declared_text = "\n".join("\t".join(row[:3]) for row in rows)

    required_commands = {
        "kitty", "google-chrome-stable", "brave-browser",
        "microsoft-edge-stable", "yandex-browser-stable", "firefox",
        "tor-browser", "mullvad-browser", "dolphin", "flameshot", "satty",
        "wpctl", "playerctl", "brightnessctl", "busctl", "notify-send",
        "wl-screenrec", "ffmpeg", "ffprobe", "pactl", "wl-color-picker",
        "wl-copy", "wtype", "wlsunset", "cliphist", "fzf", "mako", "makoctl",
        "swaylock", "swaybg", "slurp", "grim", "tesseract", "glow", "niri",
        "gsettings",
    }

    missing = sorted(cmd for cmd in required_commands if cmd not in declared_text)
    assert not missing, (
        "Niri/Wayland runtime commands referenced by dotfiles are not represented "
        f"in install/manifest.tsv package/command declarations: {missing}"
    )
