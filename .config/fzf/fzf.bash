# fzf default options
export FZF_DEFAULT_OPTS_FILE="$HOME/.config/fzf/options"

# Load fzf shell integration and keep Ctrl-R available for Atuin/Flyline.
FZF_CTRL_R_COMMAND= eval "$(fzf --bash)"

# Flyline replaces GNU Readline, so fzf keybindings must be registered
# with Flyline as well.
if enable -p 2>/dev/null | grep -q '^enable flyline$'; then
    fzf-flyline-cd-widget() {
        local command
        command="$(__fzf_cd__)" || return
        eval "$command"
    }

    flyline key bind Ctrl+t \
        'always=runBashCommand(fzf-file-widget)'

    flyline key bind Alt+c \
        'always=runBashCommand(fzf-flyline-cd-widget)'
fi
