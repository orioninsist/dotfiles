#
# ~/.bashrc
#

PATH="$(printf '%s' "$PATH" | awk -v RS=: -v ORS=: -v local_bin="$HOME/.local/bin" '$0 != local_bin && !seen[$0]++ { print }')"
PATH="${PATH%:}"
export PATH="$HOME/.local/bin:$PATH"

export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgreprc"

[[ $- != *i* ]] && return

alias ls="eza --icons=auto --group-directories-first"
alias ll="eza -lah --git --icons=auto --group-directories-first"
alias la="eza -a --icons=auto --group-directories-first"
alias lt="eza --tree --level=2 --icons=auto --group-directories-first"
alias grep="grep --color=auto"

PS1="[\u@\h \W]\$ "

export _ZO_RESOLVE_SYMLINKS=1
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"

FLYLINE_SO="$HOME/.local/lib/libflyline.so"
if [[ -f "$FLYLINE_SO" ]]; then
    enable -p | grep -q "^enable flyline$" || enable -f "$FLYLINE_SO" flyline
fi

FLYCOMP_COMPLETION_DIR="$HOME/.local/share/flyline/completions"
if [[ -d "$FLYCOMP_COMPLETION_DIR" ]]; then
    for completion_file in "$FLYCOMP_COMPLETION_DIR"/*; do
        [[ -f "$completion_file" ]] && source "$completion_file"
    done
fi
unset completion_file FLYCOMP_COMPLETION_DIR

command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"
[[ -d "$HOME/.bun/bin" ]] && export PATH="$HOME/.bun/bin:$PATH"

if [ -f "$HOME/.local/share/bash-completion/completions/kn" ]; then
    source "$HOME/.local/share/bash-completion/completions/kn"
fi

fc() {
    if [[ $# -ne 1 ]]; then
        printf 'Usage: fc <command>\n' >&2
        return 2
    fi
    local command_name="$1"
    local completion_dir="$HOME/.local/share/bash-completion/completions"
    local completion_file="$completion_dir/$command_name"
    command -v "$command_name" >/dev/null 2>&1 || { printf 'Command not found: %s\n' "$command_name" >&2; return 127; }
    command -v flycomp >/dev/null 2>&1 || { printf 'flycomp not installed\n' >&2; return 127; }
    mkdir -p "$completion_dir"
    flycomp "$command_name" > "$completion_file" || { rm -f "$completion_file"; return 1; }
    source "$completion_file"
}

[[ -r "$HOME/.config/fzf/fzf.bash" ]] && source "$HOME/.config/fzf/fzf.bash"

if command -v atuin >/dev/null 2>&1; then
    # Atuin registers preexec/precmd callbacks. bash-preexec is the dispatcher
    # that makes those callbacks run for commands entered through Flyline too.
    BASH_PREEXEC="$HOME/.local/share/bash-preexec/bash-preexec.sh"
    [[ -r "$BASH_PREEXEC" ]] && source "$BASH_PREEXEC"
    eval "$(atuin init bash --disable-ctrl-r --disable-up-arrow)"
fi

if command -v flyline >/dev/null 2>&1 && command -v atuin >/dev/null 2>&1; then
    # Keep Flyline as the line editor, but let Atuin own history search.
    # Do not append submitOrNewline: selecting history should edit the buffer,
    # not execute the selected command immediately.
    flyline key bind Ctrl+r 'always=runBashCommand("__atuin_history --keymap-mode=emacs")'
    flyline key bind Up 'editingBufferMode+cursorOnFirstLine=runBashCommand("__atuin_history --shell-up-key-binding --keymap-mode=emacs")'
fi
unset BASH_PREEXEC

[[ -r "$HOME/.config/sd/sd.bash" ]] && source "$HOME/.config/sd/sd.bash"
[[ -r "$HOME/.config/ast-grep/ast-grep.bash" ]] && source "$HOME/.config/ast-grep/ast-grep.bash"

_espanso_word_complete() {
    local cur
    cur="${COMP_WORDS[COMP_CWORD]}"
    if (( COMP_CWORD == 1 )); then
        COMPREPLY=( $(compgen -c -- "$cur") )
        return
    fi
    if (( COMP_CWORD == 2 )); then
        local dir="$HOME/.config/espanso/match"
        local file
        COMPREPLY=()
        while IFS= read -r file; do
            file="${file##*/}"
            file="${file%.yml}"
            file="${file%.yaml}"
            [[ "$file" == "$cur"* ]] && COMPREPLY+=("$file")
        done < <(find "$dir" -maxdepth 1 -type f \( -name '*.yml' -o -name '*.yaml' \) -print 2>/dev/null | sort)
    fi
}
complete -F _espanso_word_complete espanso-word
