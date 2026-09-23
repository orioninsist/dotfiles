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
