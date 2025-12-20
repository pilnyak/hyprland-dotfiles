#!/bin/bash
# Clipboard history with auto-paste
# Detects terminal windows and uses Ctrl+Shift+V, otherwise Ctrl+V

# Get selection from cliphist
selected=$(cliphist list | wofi -d -p "Clipboard")
[ -z "$selected" ] && exit 0

# Put it in clipboard
echo "$selected" | cliphist decode | wl-copy

# Small delay for clipboard to register
sleep 0.05

# Get active window class
window_class=$(hyprctl activewindow -j | jq -r '.class // empty')

# Terminal classes that need Ctrl+Shift+V
terminals="Alacritty|kitty|foot|wezterm|org.wezfurlong.wezterm|konsole|gnome-terminal|xterm"

if [[ "$window_class" =~ ^($terminals)$ ]]; then
    wtype -M ctrl -M shift -k v -m shift -m ctrl
else
    wtype -M ctrl -k v -m ctrl
fi
