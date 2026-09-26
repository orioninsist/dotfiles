from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]

SCAN_SUFFIXES = {".sh", ".kdl", ".ini", ".toml", ".service", ".path", ".desktop"}
BANNED = (
    "/home/murat/",
    "/usr/local/bin/",
)

def iter_text_files():
    tracked = subprocess.run(
        ["git", "-C", str(ROOT), "ls-files", "-z"],
        check=True,
        capture_output=True,
    ).stdout.decode().split("\0")

    for relative in tracked:
        if not relative:
            continue

        p = ROOT / relative

        if not (
            relative.startswith(".config/")
            or relative.startswith(".local/bin/")
            or relative.startswith("install/")
        ):
            continue

        if p.is_file() and (
            p.suffix in SCAN_SUFFIXES
            or p.name in {"bootstrap.sh", "install-fedora.sh"}
        ):
            yield p

def test_no_hardcoded_home_or_usr_local_bin():
    offenders = []
    for p in iter_text_files():
        try:
            text = p.read_text(errors="ignore")
        except OSError:
            continue
        for needle in BANNED:
            if needle in text:
                offenders.append(f"{p.relative_to(ROOT)}: {needle}")
    assert not offenders, "\n".join(offenders)

def test_installer_entrypoint_exists():
    p = ROOT / "install-fedora.sh"
    assert p.exists()
    assert "install/40-verify.sh" in p.read_text()
