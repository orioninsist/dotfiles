# orion-status

Minimal Zellij status plugin for the daily Niri session.

The first test intentionally implements only metrics that can be read directly
without spawning shell commands:

- network RX/TX
- CPU
- memory
- CPU/NVMe/PCH/Wi-Fi hwmon temperatures
- notification state
- camera state
- battery
- clock

Bluetooth, Niri keyboard layout, PipeWire microphone/volume and power profile are integrated through lightweight state/event bridges rather than shell polling.

Build:

    rustup target add wasm32-wasip1
    cargo build --manifest-path .config/zellij/plugins/orion-status/Cargo.toml --release --target wasm32-wasip1

The layout expects the resulting WASM at:
.config/zellij/plugins/orion-status/target/wasm32-wasip1/release/orion_status.wasm
