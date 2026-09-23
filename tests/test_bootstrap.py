from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def test_manifest_exists():
    assert (ROOT / "install/manifest.tsv").is_file()


def test_required_repo_paths():
    for p in [".config/niri", ".config/systemd/user", ".config/wayland/scripts", ".local/bin"]:
        assert (ROOT / p).exists(), p


def test_no_broken_repo_symlinks():
    broken = [p for p in ROOT.rglob("*") if p.is_symlink() and not p.exists()]
    assert not broken, broken


def test_core_commands_after_install():
    required = [
        "git", "python3", "niri", "wpctl", "wl-copy", "wl-paste",
        "fzf", "rg", "foot", "mako", "makoctl", "grim", "slurp",
        "tesseract", "notify-send", "nautilus",
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


def test_no_arch_package_manager_references_in_installer():
    forbidden = ("pacman", "yay", "paru", "apt-get", "apt ")
    text = "\n".join(
        p.read_text(errors="ignore")
        for p in (ROOT / "install").glob("*.sh")
    )
    hits = [token for token in forbidden if token in text]
    assert not hits, hits


def test_portable_runtime_paths():
    files = [
        ROOT / ".config/niri/config.kdl",
        ROOT / ".config/niri/binds/applications.kdl",
        ROOT / ".config/foot/foot.ini",
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


def test_niri_portal_backend():
    portal = (ROOT / ".config/xdg-desktop-portal/portals.conf").read_text()
    assert "org.freedesktop.impl.portal.ScreenCast=gnome" in portal
    assert "org.freedesktop.impl.portal.Screenshot=gnome" in portal
    assert "xdg-desktop-portal-wlr" not in portal
