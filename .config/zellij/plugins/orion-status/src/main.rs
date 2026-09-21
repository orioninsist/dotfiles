use chrono::Utc;
use chrono_tz::Europe::Istanbul;
use std::{collections::BTreeMap, fs};
use zellij_tile::prelude::*;

register_plugin!(State);

#[derive(Default)]
struct State {
    prev_cpu: Option<(u64, u64)>,
    prev_net: Option<(u64, u64)>,
    cpu: u64,
    mem: u64,
    down: u64,
    up: u64,
    tick: u64,
    home: String,
    host_ready: bool,
}

impl ZellijPlugin for State {
    fn load(&mut self, config: BTreeMap<String, String>) {
        self.home = config
            .get("home")
            .cloned()
            .unwrap_or_else(|| "/home/murat".to_string());
        set_selectable(true);
        request_permission(&[PermissionType::FullHdAccess]);
        subscribe(&[
            EventType::Timer,
            EventType::PermissionRequestResult,
            EventType::HostFolderChanged,
            EventType::FailedToChangeHostFolder,
        ]);
        set_timeout(1.0);
    }

    fn update(&mut self, event: Event) -> bool {
        match event {
            Event::PermissionRequestResult(PermissionStatus::Granted) => {
                change_host_folder("/".into());
                true
            }
            Event::PermissionRequestResult(PermissionStatus::Denied) => {
                set_selectable(false);
                true
            }
            Event::HostFolderChanged(_) => {
                self.host_ready = true;
                set_selectable(false);
                self.refresh();
                true
            }
            Event::FailedToChangeHostFolder(_) => {
                self.host_ready = false;
                set_selectable(false);
                true
            }
            Event::Timer(_) => {
                self.tick += 1;
                self.refresh();
                set_timeout(1.0);
                true
            }
            _ => false,
        }
    }

    fn render(&mut self, _rows: usize, cols: usize) {
        let temps = temperatures();

        let bluetooth = bluetooth_status();
        let keyboard = keyboard_layout(&self.home);
        let battery = battery();
        let notify = state_icon(
            &format!("{}/.cache/mako-popup-state", self.home),
            "disabled",
            "󰂛",
            "󰂚",
        );
        let camera = state_icon(
            &format!("{}/.cache/camera-state", self.home),
            "off",
            "󰗟",
            "󰖠",
        );
        let clock = Utc::now().with_timezone(&Istanbul).format("󰃭 %a %m/%d/%Y %H:%M:%S");

        let line = format!(
            "D {:>6}   U {:>6}   󰻠 {:>3}%   󰍛 {:>3}%   {}   {}   {}   {}  {}   {}",
            human_rate(self.down),
            human_rate(self.up),
            self.cpu,
            self.mem,
            temps,
            bluetooth,
            keyboard,
            notify,
            camera,
            battery,
        );
        let right = format!("{clock}");
        let gap = cols.saturating_sub(line.chars().count() + right.chars().count());
        print!("{}{}{}", line, " ".repeat(gap.max(1)), right);
    }
}

impl State {
    fn refresh(&mut self) {
        if let Some((total, idle)) = cpu_sample() {
            if let Some((pt, pi)) = self.prev_cpu {
                let dt = total.saturating_sub(pt);
                let di = idle.saturating_sub(pi);
                if dt > 0 {
                    self.cpu = ((dt.saturating_sub(di)) * 100 / dt).min(100);
                }
            }
            self.prev_cpu = Some((total, idle));
        }

        self.mem = memory_percent().unwrap_or(self.mem);

        if let Some((rx, tx)) = network_sample() {
            if let Some((prx, ptx)) = self.prev_net {
                self.down = rx.saturating_sub(prx);
                self.up = tx.saturating_sub(ptx);
            }
            self.prev_net = Some((rx, tx));
        }
    }
}

fn read_num(path: &str) -> Option<u64> {
    fs::read_to_string(path).ok()?.trim().parse().ok()
}

fn cpu_sample() -> Option<(u64, u64)> {
    let s = fs::read_to_string("/host/proc/stat").ok()?;
    let mut p = s.lines().next()?.split_whitespace();
    if p.next()? != "cpu" { return None; }
    let nums = p.map(|x| x.parse::<u64>().unwrap_or(0)).collect::<Vec<_>>();
    let total = nums.iter().sum();
    let idle = nums.get(3).copied().unwrap_or(0) + nums.get(4).copied().unwrap_or(0);
    Some((total, idle))
}

fn memory_percent() -> Option<u64> {
    let s = fs::read_to_string("/host/proc/meminfo").ok()?;
    let mut total = 0;
    let mut avail = 0;
    for line in s.lines() {
        if line.starts_with("MemTotal:") {
            total = line.split_whitespace().nth(1)?.parse().ok()?;
        } else if line.starts_with("MemAvailable:") {
            avail = line.split_whitespace().nth(1)?.parse().ok()?;
        }
    }
    if total == 0 { None } else { Some((total - avail) * 100 / total) }
}

fn network_sample() -> Option<(u64, u64)> {
    let s = fs::read_to_string("/host/proc/net/dev").ok()?;
    let mut rx = 0;
    let mut tx = 0;
    for line in s.lines().skip(2) {
        let (name, rest) = line.split_once(':')?;
        let name = name.trim();
        if name == "lo" { continue; }
        let v = rest.split_whitespace().collect::<Vec<_>>();
        rx += v.get(0)?.parse::<u64>().ok()?;
        tx += v.get(8)?.parse::<u64>().ok()?;
    }
    Some((rx, tx))
}

fn human_rate(v: u64) -> String {
    if v >= 1024 * 1024 {
        format!("{:.1}M", v as f64 / 1024.0 / 1024.0)
    } else if v >= 1024 {
        format!("{:.1}K", v as f64 / 1024.0)
    } else {
        format!("{}B", v)
    }
}

fn state_icon(path: &str, off_value: &str, off: &str, on: &str) -> String {
    match fs::read_to_string(path) {
        Ok(v) if v.trim() == off_value => off.to_string(),
        _ => on.to_string(),
    }
}

fn battery() -> String {
    let cap = read_num("/host/sys/class/power_supply/BAT0/capacity");
    let status = fs::read_to_string("/host/sys/class/power_supply/BAT0/status").unwrap_or_default();
    match cap {
        Some(c) if status.trim() == "Charging" => format!("󰂄 {}%", c),
        Some(c) => {
            let icon = match c {
                0..=14 => "󰁺",
                15..=29 => "󰁻",
                30..=44 => "󰁽",
                45..=59 => "󰁿",
                60..=74 => "󰂁",
                75..=89 => "󰂂",
                _ => "󰁹",
            };
            format!("{icon} {}%", c)
        }
        None => String::new(),
    }
}


fn temperatures() -> String {
    let Ok(entries) = fs::read_dir("/host/sys/class/hwmon") else {
        return String::new();
    };

    let mut cpu = None;
    let mut nvme = None;
    let mut pch = None;
    let mut wifi = None;

    for entry in entries.flatten() {
        let base = entry.path();
        let name = fs::read_to_string(base.join("name")).unwrap_or_default();
        let name = name.trim().to_ascii_lowercase();
        let Ok(raw) = fs::read_to_string(base.join("temp1_input")) else {
            continue;
        };
        let Ok(value) = raw.trim().parse::<i64>() else {
            continue;
        };
        let value = value / 1000;

        if name.contains("coretemp") || name.contains("k10temp") || name.contains("zenpower") {
            cpu.get_or_insert(value);
        } else if name.contains("nvme") {
            nvme.get_or_insert(value);
        } else if name.contains("pch") {
            pch.get_or_insert(value);
        } else if name.contains("wifi") || name.contains("iwlwifi") {
            wifi.get_or_insert(value);
        }
    }

    [
        cpu.map(|v| format!("󰔏 {v}°")),
        nvme.map(|v| format!("󰋊 {v}°")),
        pch.map(|v| format!("󰛵 {v}°")),
        wifi.map(|v| format!("󰖩 {v}°")),
    ]
    .into_iter()
    .flatten()
    .collect::<Vec<_>>()
    .join("   ")
}


fn bluetooth_status() -> String {
    let mut powered = None;

    if let Ok(entries) = fs::read_dir("/host/sys/class/rfkill") {
        for entry in entries.flatten() {
            let base = entry.path();
            let kind = fs::read_to_string(base.join("type")).unwrap_or_default();
            if kind.trim() != "bluetooth" {
                continue;
            }
            let soft = fs::read_to_string(base.join("soft")).unwrap_or_default();
            let hard = fs::read_to_string(base.join("hard")).unwrap_or_default();
            powered = Some(soft.trim() == "0" && hard.trim() == "0");
            break;
        }
    }

    let Some(true) = powered else {
        return "󰂲".to_string();
    };

    let mut connections = 0usize;
    if let Ok(entries) = fs::read_dir("/host/sys/class/bluetooth") {
        for entry in entries.flatten() {
            let name = entry.file_name();
            let name = name.to_string_lossy();
            if name.starts_with("hci") && name.contains(':') {
                connections += 1;
            }
        }
    }

    if connections > 0 {
        format!("󰂯 {connections}")
    } else {
        "󰂯".to_string()
    }
}


fn keyboard_layout(home: &str) -> String {
    let path = format!("{home}/.cache/orion-status/keyboard-layout");
    match fs::read_to_string(path) {
        Ok(value) if !value.trim().is_empty() => format!("󰌌 {}", value.trim()),
        _ => "󰌌 ?".to_string(),
    }
}
