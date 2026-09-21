use chrono::Local;
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
}

impl ZellijPlugin for State {
    fn load(&mut self, config: BTreeMap<String, String>) {
        self.home = config
            .get("home")
            .cloned()
            .unwrap_or_else(|| "/home/murat".to_string());
        set_selectable(false);
        request_permission(&[PermissionType::FullHdAccess]);
        subscribe(&[EventType::Timer]);
        self.refresh();
        set_timeout(1.0);
    }

    fn update(&mut self, event: Event) -> bool {
        if matches!(event, Event::Timer(_)) {
            self.tick += 1;
            self.refresh();
            set_timeout(1.0);
            return true;
        }
        false
    }

    fn render(&mut self, _rows: usize, cols: usize) {
        let temps = [
            ("󰔏", "/sys/class/hwmon/hwmon8/temp1_input"),
            ("󰋊", "/sys/class/hwmon/hwmon3/temp1_input"),
            ("󰛵", "/sys/class/hwmon/hwmon5/temp1_input"),
            ("󰖩", "/sys/class/hwmon/hwmon7/temp1_input"),
        ]
        .into_iter()
        .filter_map(|(icon, path)| read_num(path).map(|v| format!("{icon} {}°", v / 1000)))
        .collect::<Vec<_>>()
        .join(" ");

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
        let clock = Local::now().format("󰃭 %a %m/%d/%Y %H:%M:%S");

        let line = format!(
            "D{:>7} U{:>7}  󰻠 {:>3}%  󰍛 {:>3}%  {}  {} {}  {}",
            human_rate(self.down),
            human_rate(self.up),
            self.cpu,
            self.mem,
            temps,
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
    let s = fs::read_to_string("/proc/stat").ok()?;
    let mut p = s.lines().next()?.split_whitespace();
    if p.next()? != "cpu" { return None; }
    let nums = p.map(|x| x.parse::<u64>().unwrap_or(0)).collect::<Vec<_>>();
    let total = nums.iter().sum();
    let idle = nums.get(3).copied().unwrap_or(0) + nums.get(4).copied().unwrap_or(0);
    Some((total, idle))
}

fn memory_percent() -> Option<u64> {
    let s = fs::read_to_string("/proc/meminfo").ok()?;
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
    let s = fs::read_to_string("/proc/net/dev").ok()?;
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
    let cap = read_num("/sys/class/power_supply/BAT0/capacity");
    let status = fs::read_to_string("/sys/class/power_supply/BAT0/status").unwrap_or_default();
    match cap {
        Some(c) if status.trim() == "Charging" => format!("󰂄{}%", c),
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
            format!("{icon}{}%", c)
        }
        None => String::new(),
    }
}
