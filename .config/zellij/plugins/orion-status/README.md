# orion-status

Minimal Zellij status plugin used to evaluate replacing Waybar.

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

This is deliberate. Bluetooth, Niri keyboard layout, PipeWire microphone/volume
and power profile are not polled through shell commands in v0.1 because doing so
would undermine the performance goal of this experiment.

Build:

    rustup target add wasm32-wasip1
    cargo build --manifest-path .config/zellij/plugins/orion-status/Cargo.toml --release --target wasm32-wasip1

The layout expects the resulting WASM at:
.config/zellij/plugins/orion-status/target/wasm32-wasip1/release/orion_status.wasm
