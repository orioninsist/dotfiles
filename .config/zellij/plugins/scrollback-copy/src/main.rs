use std::collections::BTreeMap;
use zellij_tile::prelude::*;

#[derive(Default)]
struct State {
    permissions_granted: bool,
    pending_copy: bool,
}

register_plugin!(State);

impl ZellijPlugin for State {
    fn load(&mut self, _configuration: BTreeMap<String, String>) {
        subscribe(&[EventType::PermissionRequestResult]);
        request_permission(&[
            PermissionType::ReadApplicationState,
            PermissionType::ReadPaneContents,
            PermissionType::WriteToClipboard,
        ]);
    }

    fn update(&mut self, event: Event) -> bool {
        if let Event::PermissionRequestResult(status) = event {
            self.permissions_granted = status == PermissionStatus::Granted;
            if self.permissions_granted && self.pending_copy {
                self.pending_copy = false;
                self.copy_focused_scrollback();
            }
        }
        false
    }

    fn pipe(&mut self, pipe_message: PipeMessage) -> bool {
        if pipe_message.name != "copy_scrollback" {
            return false;
        }

        if self.permissions_granted {
            self.copy_focused_scrollback();
        } else {
            self.pending_copy = true;
        }
        false
    }
}

impl State {
    fn copy_focused_scrollback(&mut self) {
        let Ok((_tab_index, pane_id)) = get_focused_pane_info() else {
            return;
        };

        let Ok(contents) = get_pane_scrollback(pane_id, true) else {
            return;
        };

        let mut lines = contents.lines_above_viewport;
        lines.extend(contents.viewport);
        lines.extend(contents.lines_below_viewport);

        copy_to_clipboard(lines.join("\n"));
    }
}
