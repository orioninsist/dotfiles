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
    for cmd in ["niri", "ly"]:
        assert shutil.which(cmd), cmd

    rpm = subprocess.run(
        ["rpm", "-q", "mesa-dri-drivers", "mesa-libgbm"],
        capture_output=True,
        text=True,
    )
    assert rpm.returncode == 0, rpm.stdout + rpm.stderr

    session = Path("/usr/share/wayland-sessions/niri.desktop")
    assert session.is_file(), session

    enabled = subprocess.run(
        ["systemctl", "is-enabled", "ly@tty2.service"],
        capture_output=True,
        text=True,
    )
    assert enabled.returncode == 0, enabled.stdout + enabled.stderr

    default_target = subprocess.run(
        ["systemctl", "get-default"],
        capture_output=True,
        text=True,
    )
    assert default_target.stdout.strip() == "graphical.target", default_target.stdout + default_target.stderr


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


def test_niri_session_entrypoint_and_ly_acceptance():
    session = Path("/usr/share/wayland-sessions/niri.desktop")
    assert session.is_file(), session
    text = session.read_text(errors="ignore")
    assert "Exec=niri-session" in text, text

    niri_session = shutil.which("niri-session")
    assert niri_session, "niri-session not found in PATH"

    ly_unit = Path("/usr/lib/systemd/system/ly@.service")
    assert ly_unit.is_file(), ly_unit

    enabled = subprocess.run(
        ["systemctl", "is-enabled", "ly@tty2.service"],
        capture_output=True,
        text=True,
    )
    assert enabled.returncode == 0, enabled.stdout + enabled.stderr


def test_ly_custom_niri_session_is_absolute():
    custom = Path("/etc/ly/custom-sessions/niri.desktop")
    assert custom.is_file(), custom
    text = custom.read_text(errors="ignore")
    exec_line = next((line for line in text.splitlines() if line.startswith("Exec=")), "")
    assert exec_line, text

    niri_session = shutil.which("niri-session")
    assert niri_session, "niri-session not found in PATH"
    assert Path(exec_line.removeprefix("Exec=")).resolve() == Path(niri_session).resolve(), (
        exec_line,
        niri_session,
    )

    packaged = Path("/usr/share/wayland-sessions/niri.desktop")
    assert packaged.is_file(), packaged


def test_ly_selinux_policy_is_installed():
    rpm = subprocess.run(
        ["rpm", "-q", "selinux-policy-devel"],
        capture_output=True,
        text=True,
    )
    assert rpm.returncode == 0, rpm.stdout + rpm.stderr

    policy_source = Path(__file__).resolve().parents[1] / "install/selinux/ly-local.te"
    assert policy_source.is_file(), policy_source
    policy_text = policy_source.read_text(errors="ignore")
    assert "allow unconfined_service_t unconfined_t:process transition;" in policy_text

    modules = subprocess.run(
        ["sudo", "semodule", "-l"],
        capture_output=True,
        text=True,
    )
    assert modules.returncode == 0, modules.stdout + modules.stderr
    assert any(line.split() and line.split()[0] == "ly-local" for line in modules.stdout.splitlines())

    getenforce = shutil.which("getenforce")
    assert getenforce, "getenforce not found"
    mode = subprocess.run(
        [getenforce],
        capture_output=True,
        text=True,
        check=True,
    ).stdout.strip()
    assert mode == "Enforcing", mode
