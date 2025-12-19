#!/bin/bash

#===============================================================================
# Wallpaper Rotation Script
# ~/.config/scripts/theme/wallpaper-rotate.sh
# Description: Rotates wallpapers and syncs theme (matches original implementation)
#===============================================================================

WALLPAPER_DIR="$HOME/Pictures/Wallpapers/Black"
SCRIPT_DIR="$HOME/.config/scripts/theme"

# Get random wallpaper (excluding current)
get_random_wallpaper() {
    local current
    current=$(swww query 2>/dev/null | grep -oP '(?<=image: ).*' | head -n1)
    find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) | grep -v "$current" | shuf -n 1
}

# Set wallpaper with smooth fade transition
set_wallpaper() {
    local wallpaper="$1"
    swww img "$wallpaper" \
        --transition-type fade \
        --transition-duration 2 \
        --transition-fps 60
}

# Main
main() {
    wallpaper=$(get_random_wallpaper)

    if [[ -z "$wallpaper" ]]; then
        echo "No wallpapers found in $WALLPAPER_DIR"
        exit 1
    fi

    # Set wallpaper first (swww handles transition smoothly)
    set_wallpaper "$wallpaper"

    # Wait for transition to mostly complete before theme sync
    sleep 2.5

    # Run theme sync (waybar auto-reloads via reload_style_on_change)
    "$SCRIPT_DIR/theme-sync.sh" 2>/dev/null
}

main "$@"
