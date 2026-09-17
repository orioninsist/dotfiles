# ~/.bash_profile

[[ -f ~/.bashrc ]] && . ~/.bashrc

# Desktop session
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_DESKTOP=sway

# Qt / Wayland
export QT_QPA_PLATFORM='wayland;xcb'

# Global dark appearance
export CALIBRE_USE_SYSTEM_THEME=1

# Default terminal editor
export EDITOR="nvim"
export VISUAL="nvim"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Added by Toolbox App
export PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/scripts"
