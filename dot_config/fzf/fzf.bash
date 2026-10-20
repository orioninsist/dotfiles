# fzf default options
export FZF_DEFAULT_OPTS_FILE="$HOME/.config/fzf/options"

# Use fd for fzf file/directory discovery.
#
# --hidden:
#   Include dotfiles such as .bashrc and .config.
#
# --exclude .git:
#   Keep Git's internal metadata out of interactive results.
#
# We intentionally do not use --no-ignore, so fd continues to respect
# .gitignore and other ignore rules.
export FZF_CTRL_T_COMMAND='fd --hidden --exclude .git'
export FZF_ALT_C_COMMAND='fd --hidden --type d --exclude .git'

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

   fzf-flyline-file-widget() {
       local selected
       selected="$(fd --hidden --exclude .git | fzf)" || return
       [[ -n "$selected" ]] || return

       printf -v selected '%q' "$selected"
       READLINE_LINE="${READLINE_LINE:0:READLINE_POINT}${selected}${READLINE_LINE:READLINE_POINT}"
       READLINE_POINT=$((READLINE_POINT + ${#selected}))
   }

   flyline key bind Ctrl+t \
       'always=runBashCommand("fzf-flyline-file-widget")'

    flyline key bind Alt+c \
        'always=runBashCommand(fzf-flyline-cd-widget)'
fi
