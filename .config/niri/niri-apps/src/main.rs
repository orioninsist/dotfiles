use gtk::prelude::*;
use gtk::{Application, ApplicationWindow, Box as GtkBox, Button, Label, Orientation, ScrolledWindow, Switch};
use serde::Deserialize;
use std::{fs, path::PathBuf, process::Command};

const APP_ID: &str = "dev.orioninsist.NiriApps";

#[derive(Debug, Deserialize)]
struct Config { workspaces: Vec<Workspace> }
#[derive(Debug, Deserialize)]
struct Workspace { id: u8, apps: Vec<AppEntry> }
#[derive(Debug, Deserialize)]
struct AppEntry { name: String }

fn home() -> PathBuf { PathBuf::from(std::env::var_os("HOME").expect("HOME is not set")) }
fn config_path() -> PathBuf { home().join(".config/niri/apps.json") }
fn load_config() -> Config {
    let data = fs::read_to_string(config_path()).expect("cannot read apps.json");
    serde_json::from_str(&data).expect("invalid apps.json")
}
fn state_path() -> PathBuf {
    std::env::var_os("XDG_STATE_HOME").map(PathBuf::from)
        .unwrap_or_else(|| home().join(".local/state")).join("niri-session/enabled")
}
fn startup_enabled() -> bool {
    fs::read_to_string(state_path()).map(|v| v.trim() == "on").unwrap_or(false)
}
fn set_startup(enabled: bool) {
    let mode = if enabled { "on" } else { "off" };
    let _ = Command::new(home().join(".config/niri/scripts/niri-session")).arg(mode).status();
    let _ = Command::new("pkill").args(["-RTMIN+8", "waybar"]).status();
}
fn build_ui(app: &Application) {
    let config = load_config();
    let root = GtkBox::new(Orientation::Vertical, 12);
    root.set_margin_top(18); root.set_margin_bottom(18); root.set_margin_start(18); root.set_margin_end(18);

    let header = GtkBox::new(Orientation::Horizontal, 12);
    let title = Label::new(Some("Niri Apps"));
    title.add_css_class("title-1"); title.set_hexpand(true); title.set_halign(gtk::Align::Start);
    let state_label = Label::new(Some(if startup_enabled() { "ACTIVE" } else { "PASSIVE" }));
    state_label.add_css_class("heading");
    let state = Switch::new(); state.set_active(startup_enabled());
    let state_text = state_label.clone();
    state.connect_state_set(move |_, enabled| {
        set_startup(enabled);
        state_text.set_text(if enabled { "ACTIVE" } else { "PASSIVE" });
        glib::Propagation::Proceed
    });
    header.append(&title); header.append(&state_label); header.append(&state); root.append(&header);

    for workspace_id in 1..=10 {
        let row = GtkBox::new(Orientation::Horizontal, 10); row.set_height_request(58);
        let tag = Label::new(Some(&format!("TAG {workspace_id}")));
        tag.set_width_chars(7); tag.set_xalign(0.0); tag.add_css_class("heading"); row.append(&tag);
        let apps = GtkBox::new(Orientation::Horizontal, 8);
        if let Some(workspace) = config.workspaces.iter().find(|w| w.id == workspace_id) {
            for entry in &workspace.apps {
                let card = Button::with_label(&entry.name); card.add_css_class("pill"); apps.append(&card);
            }
        }
        let add = Button::with_label("+"); add.set_tooltip_text(Some("Add application")); apps.append(&add);
        let horizontal = ScrolledWindow::new();
        horizontal.set_policy(gtk::PolicyType::Automatic, gtk::PolicyType::Never);
        horizontal.set_hexpand(true); horizontal.set_child(Some(&apps)); row.append(&horizontal); root.append(&row);
    }
    let vertical = ScrolledWindow::new();
    vertical.set_policy(gtk::PolicyType::Never, gtk::PolicyType::Automatic); vertical.set_child(Some(&root));
    let window = ApplicationWindow::builder().application(app).title("Niri Apps")
        .default_width(1100).default_height(720).child(&vertical).build();
    window.present();
}
fn main() {
    let app = Application::builder().application_id(APP_ID).build();
    app.connect_activate(build_ui); app.run();
}
