from pathlib import Path
import os
import shutil

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
    required = ["git", "python3", "niri", "wpctl", "wl-copy", "wl-paste", "fzf", "rg"]
    missing = [x for x in required if shutil.which(x) is None]
    assert not missing, missing

def test_user_config_links_after_deploy():
    home = Path.home()
    for name in ["niri", "systemd", "wayland"]:
        p = home / ".config" / name
        assert p.is_symlink(), p
        assert p.resolve() == (ROOT / ".config" / name).resolve()
