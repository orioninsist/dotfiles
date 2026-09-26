# ~/.bash_profile

[[ -f ~/.bashrc ]] && . ~/.bashrc

# Desktop session

# Qt / Wayland
export QT_QPA_PLATFORM='wayland;xcb'
export QT_QPA_PLATFORMTHEME='qt6ct'
export KDE_COLOR_SCHEME='CatppuccinMochaMauve'

# Default terminal editor
export EDITOR="nvim"
export VISUAL="nvim"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Added by Toolbox App
export PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/scripts"
