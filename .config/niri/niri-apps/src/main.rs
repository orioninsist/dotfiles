use gtk::gdk;
use gtk::prelude::*;
use gtk::{Application, ApplicationWindow, Box as GtkBox, Button, Dialog, Entry, Label, Orientation, ResponseType, ScrolledWindow, Switch};
use serde::{Deserialize, Serialize};
use std::{cell::RefCell, fs, path::{Path, PathBuf}, process::Command, rc::Rc};

const APP_ID: &str = "dev.orioninsist.NiriApps";

#[derive(Debug, Clone, Serialize, Deserialize)]
struct Config { version: u8, workspaces: Vec<Workspace> }
#[derive(Debug, Clone, Serialize, Deserialize)]
struct Workspace { id: u8, apps: Vec<AppEntry> }
#[derive(Debug, Clone, Serialize, Deserialize)]
struct AppEntry {
    name: String,
    app_id: String,
    exec: Vec<String>,
    #[serde(default = "yes")] startup: bool,
}
fn yes() -> bool { true }
fn home() -> PathBuf { PathBuf::from(std::env::var_os("HOME").expect("HOME is not set")) }
fn config_path() -> PathBuf { home().join(".config/niri/apps.json") }
fn load_config() -> Config {
    serde_json::from_str(&fs::read_to_string(config_path()).expect("cannot read apps.json")).expect("invalid apps.json")
}
fn save_config(config: &Config) {
    let tmp = config_path().with_extension("json.tmp");
    let data = serde_json::to_string_pretty(config).expect("serialize apps.json") + "\n";
    fs::write(&tmp, data).expect("write apps.json");
    fs::rename(tmp, config_path()).expect("replace apps.json");
}
fn state_path() -> PathBuf {
    std::env::var_os("XDG_STATE_HOME").map(PathBuf::from)
        .unwrap_or_else(|| home().join(".local/state")).join("niri-session/enabled")
}
fn startup_enabled() -> bool { fs::read_to_string(state_path()).map(|v| v.trim() == "on").unwrap_or(false) }
fn set_startup(enabled: bool) {
    let mode = if enabled { "on" } else { "off" };
    let _ = Command::new(home().join(".config/niri/scripts/niri-session")).arg(mode).status();
}
fn desktop_dirs() -> Vec<PathBuf> {
    vec![home().join(".local/share/applications"), PathBuf::from("/usr/local/share/applications"), PathBuf::from("/usr/share/applications")]
}
fn desktop_value(path: &Path, key: &str) -> Option<String> {
    let text = fs::read_to_string(path).ok()?;
    let mut in_main = false;
    for line in text.lines() {
        if line == "[Desktop Entry]" { in_main = true; continue; }
        if in_main && line.starts_with('[') { break; }
        if in_main {
            if let Some(value) = line.strip_prefix(&format!("{key}=")) { return Some(value.trim().to_string()); }
        }
    }
    None
}
fn clean_exec(exec: &str) -> Vec<String> {
    shlex::split(exec).unwrap_or_default().into_iter()
        .filter_map(|arg| {
            if arg.starts_with('%') { return None; }
            if arg.contains('%') { return None; }
            Some(arg)
        }).collect()
}
fn app_id_from_exec(exec: &[String], startup_wm_class: Option<String>, desktop_stem: &str) -> String {
    let app = exec.iter().find_map(|x| x.strip_prefix("--app-id="));
    if let Some(id) = app {
        let profile = exec.iter().find_map(|x| x.strip_prefix("--profile-directory=")).unwrap_or("Default");
        return format!("chrome-{id}-{profile}");
    }
    startup_wm_class.unwrap_or_else(|| desktop_stem.to_string())
}
fn find_in_path(name: &str) -> Option<String> {
    if name.contains('/') { return Path::new(name).is_file().then(|| name.to_string()); }
    let path = std::env::var_os("PATH")?;
    std::env::split_paths(&path)
        .map(|dir| dir.join(name))
        .find(|p| p.is_file())
        .map(|p| p.to_string_lossy().into_owned())
}
fn exec_from_pid(pid: u64) -> Vec<String> {
    let proc = PathBuf::from(format!("/proc/{pid}"));
    if let Ok(bytes) = fs::read(proc.join("cmdline")) {
        let args: Vec<String> = bytes.split(|b| *b == 0)
            .filter(|s| !s.is_empty())
            .filter_map(|s| String::from_utf8(s.to_vec()).ok())
            .collect();
        if !args.is_empty() { return args; }
    }
    fs::read_link(proc.join("exe"))
        .ok()
        .map(|p| vec![p.to_string_lossy().into_owned()])
        .unwrap_or_default()
}
fn live_windows() -> Vec<(String, String, u64)> {
    let Ok(output) = Command::new("niri").args(["msg", "--json", "windows"]).output() else { return Vec::new() };
    let Ok(value) = serde_json::from_slice::<serde_json::Value>(&output.stdout) else { return Vec::new() };
    let Some(windows) = value.as_array() else { return Vec::new() };
    let mut out = Vec::new();
    for w in windows {
        let Some(app_id) = w.get("app_id").and_then(|v| v.as_str()).filter(|s| !s.is_empty()) else { continue };
        if app_id == APP_ID { continue; }
        let title = w.get("title").and_then(|v| v.as_str()).unwrap_or("");
        let name = if title.trim().is_empty() { app_id } else { title };
        let pid = w.get("pid").and_then(|v| v.as_u64()).unwrap_or(0);
        out.push((name.to_string(), app_id.to_string(), pid));
    }
    out.sort();
    out.dedup_by(|a,b| a.1 == b.1);
    out
}
fn build_catalog() -> Vec<AppEntry> {
    let live = live_windows();
    let mut out = Vec::new();
    for dir in desktop_dirs() {
        let Ok(entries) = fs::read_dir(dir) else { continue };
        for file in entries.flatten() {
            let path = file.path();
            if path.extension().and_then(|x| x.to_str()) != Some("desktop") { continue; }
            let Some(name) = desktop_value(&path, "Name") else { continue };
            let Some(exec_text) = desktop_value(&path, "Exec") else { continue };
            let exec = clean_exec(&exec_text);
            if exec.is_empty() { continue; }
            let stem = path.file_stem().and_then(|x| x.to_str()).unwrap_or(&name);
            let mut app_id = app_id_from_exec(&exec, desktop_value(&path, "StartupWMClass"), stem);
            let needle = name.to_lowercase();
            let matches: Vec<_> = live.iter().filter(|(title,id,_)| {
                let hay = format!("{title} {id}").to_lowercase();
                hay.contains(&needle) || needle.contains(&id.to_lowercase())
            }).collect();
            if matches.len() == 1 { app_id = matches[0].1.clone(); }
            out.push(AppEntry { name, app_id, exec, startup: true });
        }
    }
    // Open Niri windows are a second discovery source. This catches local/Tauri
    // apps without a desktop file. If their app-id is also an executable name,
    // resolve it from PATH so ACTIVE startup can launch it later.
    for (title, app_id, pid) in live {
        if out.iter().any(|a| a.app_id == app_id) { continue; }
        let mut exec = if pid > 0 { exec_from_pid(pid) } else { Vec::new() };
        if exec.is_empty() { exec = find_in_path(&app_id).map(|p| vec![p]).unwrap_or_default(); }
        let startup = !exec.is_empty();
        out.push(AppEntry { name: title, app_id, exec, startup });
    }
    out.sort_by(|a,b| a.name.to_lowercase().cmp(&b.name.to_lowercase()));
    out.dedup_by(|a,b| a.app_id == b.app_id || (!a.exec.is_empty() && a.exec == b.exec));
    out
}
fn filter_catalog(catalog: &[AppEntry], query: &str) -> Vec<AppEntry> {
    let q = query.trim().to_lowercase();
    if q.is_empty() { return Vec::new(); }
    catalog.iter()
        .filter(|a| a.name.to_lowercase().contains(&q) || a.app_id.to_lowercase().contains(&q))
        .take(30).cloned().collect()
}
fn remove_app(config: &mut Config, app_id: &str) {
    for ws in &mut config.workspaces { ws.apps.retain(|a| a.app_id != app_id); }
}
fn insert_app(config: &mut Config, workspace: u8, index: usize, entry: AppEntry) {
    let exec = entry.exec.clone();
    for ws in &mut config.workspaces {
        ws.apps.retain(|a| a.app_id != entry.app_id && (exec.is_empty() || a.exec != exec));
    }
    if let Some(ws) = config.workspaces.iter_mut().find(|w| w.id == workspace) {
        let at = index.min(ws.apps.len()); ws.apps.insert(at, entry);
    }
}
fn add_dialog(parent: &ApplicationWindow, workspace: u8, model: Rc<RefCell<Config>>, refresh: Rc<dyn Fn()>) {
    let dialog = Dialog::builder().transient_for(parent).modal(true).title(format!("Add to TAG {workspace}")).default_width(560).default_height(480).build();
    dialog.add_button("Close", ResponseType::Close);
    let content = dialog.content_area();
    let search = Entry::new(); search.set_placeholder_text(Some("Type an installed application name…")); content.append(&search);
    let results = GtkBox::new(Orientation::Vertical, 6);
    let catalog = Rc::new(build_catalog());
    let scroll = ScrolledWindow::new(); scroll.set_vexpand(true); scroll.set_child(Some(&results)); content.append(&scroll);
    let render: Rc<dyn Fn(String)> = {
        let results=results.clone(); let dialog=dialog.clone(); let model=model.clone(); let refresh=refresh.clone(); let catalog=catalog.clone();
        Rc::new(move |text: String| {
            while let Some(child)=results.first_child() { results.remove(&child); }
            if text.trim().is_empty() { return; }
            for found in filter_catalog(&catalog, &text) {
                let button=Button::with_label(&found.name);
                let found2=found.clone(); let model2=model.clone(); let refresh2=refresh.clone(); let dialog2=dialog.clone();
                button.connect_clicked(move |_| {
                    let mut c=model2.borrow_mut(); let index=c.workspaces.iter().find(|w|w.id==workspace).map(|w|w.apps.len()).unwrap_or(0);
                    insert_app(&mut c,workspace,index,found2.clone()); save_config(&c); drop(c); refresh2(); dialog2.close();
                });
                results.append(&button);
            }
        })
    };
    let render2=render.clone(); search.connect_changed(move |e| render2(e.text().to_string()));
    dialog.connect_response(|d,_|d.close()); dialog.present(); search.grab_focus();
}
fn edit_dialog(parent:&ApplicationWindow, entry:AppEntry, model:Rc<RefCell<Config>>, refresh:Rc<dyn Fn()>) {
    let dialog=Dialog::builder().transient_for(parent).modal(true).title(&entry.name).build();
    dialog.add_button("Cancel",ResponseType::Cancel); dialog.add_button("Delete",ResponseType::Reject); dialog.add_button("Save",ResponseType::Accept);
    let name=Entry::new(); name.set_text(&entry.name);
    dialog.content_area().append(&Label::new(Some("Name"))); dialog.content_area().append(&name);
    let startup_row=GtkBox::new(Orientation::Horizontal,12);
    let startup_label=Label::new(Some("Open automatically when ACTIVE")); startup_label.set_hexpand(true); startup_label.set_xalign(0.0);
    let startup=Switch::new(); startup.set_active(entry.startup);
    startup_row.append(&startup_label); startup_row.append(&startup); dialog.content_area().append(&startup_row);
    dialog.connect_response(move |d,r| {
        if r==ResponseType::Reject { let mut c=model.borrow_mut(); remove_app(&mut c,&entry.app_id); save_config(&c); drop(c); refresh(); }
        else if r==ResponseType::Accept { let mut c=model.borrow_mut(); for ws in &mut c.workspaces { if let Some(a)=ws.apps.iter_mut().find(|a|a.app_id==entry.app_id) { a.name=name.text().to_string(); a.startup=startup.is_active(); } } save_config(&c); drop(c); refresh(); }
        d.close();
    }); dialog.present();
}
fn build_ui(app:&Application) {
    let model=Rc::new(RefCell::new(load_config()));
    let window=ApplicationWindow::builder().application(app).title("Niri Apps").default_width(1100).default_height(720).build();
    let root=GtkBox::new(Orientation::Vertical,12); root.set_margin_top(18);root.set_margin_bottom(18);root.set_margin_start(18);root.set_margin_end(18);
    let header=GtkBox::new(Orientation::Horizontal,12);
    let title=Label::new(Some("Niri Apps"));title.add_css_class("title-1");title.set_hexpand(true);title.set_halign(gtk::Align::Start);
    let state_label=Label::new(Some(if startup_enabled(){"ACTIVE"}else{"PASSIVE"}));state_label.add_css_class("heading");
    let state=Switch::new();state.set_active(startup_enabled());let sl=state_label.clone();
    state.connect_state_set(move|_,v|{set_startup(v);sl.set_text(if v{"ACTIVE"}else{"PASSIVE"});gtk::glib::Propagation::Proceed});
    header.append(&title);header.append(&state_label);header.append(&state);root.append(&header);
    let rows=GtkBox::new(Orientation::Vertical,8); root.append(&rows);
    let refresh_slot:Rc<RefCell<Option<Rc<dyn Fn()>>>>=Rc::new(RefCell::new(None));
    let refresh:Rc<dyn Fn()> = {
        let rows=rows.clone();let model=model.clone();let window=window.clone();let slot=refresh_slot.clone();
        Rc::new(move||{
            while let Some(child)=rows.first_child(){rows.remove(&child);}
            for wid in 1..=10u8 {
                let row=GtkBox::new(Orientation::Horizontal,10);row.set_height_request(58);
                let tag=Label::new(Some(&format!("TAG {wid}")));tag.set_width_chars(7);tag.set_xalign(0.0);tag.add_css_class("heading");row.append(&tag);
                let cards=GtkBox::new(Orientation::Horizontal,8);
                let entries=model.borrow().workspaces.iter().find(|w|w.id==wid).map(|w|w.apps.clone()).unwrap_or_default();
                for (idx,entry) in entries.into_iter().enumerate() {
                    let card=Button::with_label(&entry.name);card.add_css_class("pill");card.set_tooltip_text(Some("Click: edit/delete · Drag: reorder or move TAG"));
                    let e=entry.clone();let m=model.clone();let w=window.clone();let s=slot.clone();
                    card.connect_clicked(move |_|{if let Some(r)=s.borrow().clone(){edit_dialog(&w,e.clone(),m.clone(),r);}});
                    let source=gtk::DragSource::builder().actions(gdk::DragAction::MOVE).build();
                    let id=entry.app_id.clone();source.connect_prepare(move|_,_,_|Some(gdk::ContentProvider::for_value(&id.to_value())));card.add_controller(source);
                    let target=gtk::DropTarget::new(String::static_type(),gdk::DragAction::MOVE);
                    let m=model.clone();let s=slot.clone();
                    target.connect_drop(move|_,value,_,_|{
                        let Ok(id)=value.get::<String>() else{return false}; let mut c=m.borrow_mut();
                        let found=c.workspaces.iter().flat_map(|w|w.apps.iter()).find(|a|a.app_id==id).cloned();
                        if let Some(e)=found{insert_app(&mut c,wid,idx,e);save_config(&c);drop(c);if let Some(r)=s.borrow().clone(){r();}true}else{false}
                    });card.add_controller(target);cards.append(&card);
                }
                let add=Button::with_label("+");add.set_tooltip_text(Some("Add installed application"));let m=model.clone();let w=window.clone();let s=slot.clone();
                add.connect_clicked(move |_|{if let Some(r)=s.borrow().clone(){add_dialog(&w,wid,m.clone(),r);}});
                let end_target=gtk::DropTarget::new(String::static_type(),gdk::DragAction::MOVE);let m=model.clone();let s=slot.clone();
                end_target.connect_drop(move|_,value,_,_|{let Ok(id)=value.get::<String>()else{return false};let mut c=m.borrow_mut();let found=c.workspaces.iter().flat_map(|w|w.apps.iter()).find(|a|a.app_id==id).cloned();if let Some(e)=found{let i=c.workspaces.iter().find(|w|w.id==wid).map(|w|w.apps.len()).unwrap_or(0);insert_app(&mut c,wid,i,e);save_config(&c);drop(c);if let Some(r)=s.borrow().clone(){r();}true}else{false}});
                add.add_controller(end_target);cards.append(&add);
                let horizontal=ScrolledWindow::new();horizontal.set_policy(gtk::PolicyType::Automatic,gtk::PolicyType::Never);horizontal.set_hexpand(true);horizontal.set_child(Some(&cards));row.append(&horizontal);rows.append(&row);
            }
        })
    };
    *refresh_slot.borrow_mut()=Some(refresh.clone());refresh();
    let vertical=ScrolledWindow::new();vertical.set_policy(gtk::PolicyType::Never,gtk::PolicyType::Automatic);vertical.set_child(Some(&root));window.set_child(Some(&vertical));window.present();
}
fn main(){let app=Application::builder().application_id(APP_ID).build();app.connect_activate(build_ui);app.run();}
