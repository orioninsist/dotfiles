# User-local executable paths.
export PATH="$HOME/.local/bin:$PATH"

# JetBrains Toolbox adds its scripts directory when present.
if [[ -d "$HOME/.local/share/JetBrains/Toolbox/scripts" ]]; then
    export PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/scripts"
fi
