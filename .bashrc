#
# ~/.bashrc
#

PATH="$(printf '%s' "$PATH" | awk -v RS=: -v ORS=: -v local_bin="$HOME/.local/bin" '$0 != local_bin && !seen[$0]++ { print }')"
PATH="${PATH%:}"
export PATH="$HOME/.local/bin:$PATH"

# ripgrep
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgreprc"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# eza
alias ls="eza --icons=auto --group-directories-first"
alias ll="eza -lah --git --icons=auto --group-directories-first"
alias la="eza -a --icons=auto --group-directories-first"
alias lt="eza --tree --level=2 --icons=auto --group-directories-first"
alias grep="grep --color=auto"

PS1="[\u@\h \W]\$ "

export _ZO_RESOLVE_SYMLINKS=1
eval "$(zoxide init bash)"

enable -p | grep -q "^enable flyline$" || enable -f /mnt/local/projects/flyline/target/release/libflyline.so flyline

# Load completions synthesized by flycomp.
FLYCOMP_COMPLETION_DIR="$HOME/.local/share/flyline/completions"
if [[ -d "$FLYCOMP_COMPLETION_DIR" ]]; then
    for completion_file in "$FLYCOMP_COMPLETION_DIR"/*; do
        [[ -f "$completion_file" ]] && source "$completion_file"
    done
fi
unset completion_file FLYCOMP_COMPLETION_DIR

# Automatically attach Kitty to the persistent Zellij session.
if [ -z "$ZELLIJ" ] && [ "$TERM" = "xterm-kitty" ]; then
    exec zellij attach --create "orioninsist"
fi

# Starship prompt
eval "$(starship init bash)"
export PATH="$HOME/.bun/bin:$PATH"

# Knowledge global terminal completion
if [ -f ~/.local/share/bash-completion/completions/kn ]; then
    source ~/.local/share/bash-completion/completions/kn
fi

# Generate and immediately load a Bash completion with flycomp.
fc() {
    if [[ $# -ne 1 ]]; then
        printf 'Usage: fc <command>\n' >&2
        return 2
    fi

    local command_name="$1"
    local completion_dir="$HOME/.local/share/bash-completion/completions"
    local completion_file="$completion_dir/$command_name"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        printf 'Command not found: %s\n' "$command_name" >&2
        return 127
    fi

    mkdir -p "$completion_dir"

    if ! flycomp "$command_name" > "$completion_file"; then
        rm -f "$completion_file"
        printf 'Failed to generate completion for: %s\n' "$command_name" >&2
        return 1
    fi

    source "$completion_file"

    printf 'Completion installed and loaded: %s\n' "$command_name"
}

# fzf shell integration
if [[ -r "$HOME/.config/fzf/fzf.bash" ]]; then
    source "$HOME/.config/fzf/fzf.bash"
fi

# Atuin shell history
eval "$(atuin init bash)"

# Flyline integration for Atuin.
flyline key bind Ctrl+r 'always=runBashCommand(__atuin_widget_run)+submitOrNewline'
flyline key bind Up 'editingBufferMode+cursorOnFirstLine=runBashCommand("__atuin_history --shell-up-key-binding --keymap-mode=emacs")+submitOrNewline'
# sd shell integration
if [[ -r "$HOME/.config/sd/sd.bash" ]]; then
    source "$HOME/.config/sd/sd.bash"
fi
