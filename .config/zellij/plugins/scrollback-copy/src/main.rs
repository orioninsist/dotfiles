use std::collections::BTreeMap;
use zellij_tile::prelude::*;

#[derive(Default)]
struct State;

register_plugin!(State);

impl ZellijPlugin for State {
    fn load(&mut self, _configuration: BTreeMap<String, String>) {
        request_permission(&[
            PermissionType::ReadApplicationState,
            PermissionType::ReadPaneContents,
            PermissionType::WriteToClipboard,
        ]);
    }

    fn pipe(&mut self, pipe_message: PipeMessage) -> bool {
        if pipe_message.name != "copy_scrollback" {
            return false;
        }

        let Ok((_tab_index, pane_id)) = get_focused_pane_info() else {
            return false;
        };

        let Ok(contents) = get_pane_scrollback(pane_id, true) else {
            return false;
        };

        let mut lines = contents.lines_above_viewport;
        lines.extend(contents.viewport);
        lines.extend(contents.lines_below_viewport);

        copy_to_clipboard(lines.join("\n"));
        false
    }
}
