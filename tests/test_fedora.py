from pathlib import Path
import shutil
import subprocess


def _os_release():
    data = {}
    for line in Path("/etc/os-release").read_text().splitlines():
        if "=" in line:
            key, value = line.split("=", 1)
            data[key] = value.strip('"')
    return data


def test_fedora_44():
    osr = _os_release()
    assert osr.get("ID") == "fedora"
    assert osr.get("VERSION_ID") == "44"


def test_dnf_exists():
    assert shutil.which("dnf")


def test_niri_exists():
    assert shutil.which("niri")


def test_qemu_guest_agent_when_virtualized():
    virt = subprocess.run(["systemd-detect-virt", "--vm"], capture_output=True)
    if virt.returncode != 0:
        return
    state = subprocess.run(
        ["systemctl", "is-active", "qemu-guest-agent.service"],
        capture_output=True,
        text=True,
    )
    assert state.returncode == 0, state.stdout + state.stderr


def test_graphics_runtime_and_display_manager():
    for cmd in ["niri", "niri-session"]:
        assert shutil.which(cmd), cmd

    rpm = subprocess.run(
        ["rpm", "-q", "mesa-dri-drivers", "mesa-libgbm"],
        capture_output=True,
        text=True,
    )
    assert rpm.returncode == 0, rpm.stdout + rpm.stderr

    session = Path("/usr/share/wayland-sessions/niri.desktop")
    assert session.is_file(), session


def test_niri_smithay_runtime_packages():
    packages = [
        "niri",
        "mesa-dri-drivers",
        "mesa-libgbm",
        "mesa-libEGL",
        "libwayland-server",
        "libseat",
        "libinput",
        "libxkbcommon",
        "libdisplay-info",
        "pixman",
        "libglvnd-egl",
        "xwayland-satellite",
        "xorg-x11-server-Xwayland",
        "xdg-desktop-portal-gtk",
        "xdg-desktop-portal-gnome",
        "gnome-keyring",
    ]
    rpm = subprocess.run(
        ["rpm", "-q", *packages],
        capture_output=True,
        text=True,
    )
    assert rpm.returncode == 0, rpm.stdout + rpm.stderr

    for cmd in ["niri", "niri-session", "Xwayland"]:
        assert shutil.which(cmd), cmd


def test_niri_session_entrypoint():
    session = Path("/usr/share/wayland-sessions/niri.desktop")
    assert session.is_file(), session

    text = session.read_text(errors="ignore")
    assert "Exec=niri-session" in text, text

    assert shutil.which("niri-session"), "niri-session not found"




