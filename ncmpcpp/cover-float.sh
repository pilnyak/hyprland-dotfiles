#!/bin/bash
# Floating cover art viewer for MPD
# Copies cover to fixed path, restarts imv on change

MUSIC_DIR="/mnt/AJI/Music"
COVER_PATH="/tmp/mpd_cover_current.jpg"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
FALLBACK_PATH="/tmp/mpd_cover_fallback.jpg"

find_cover_in_dir() {
    local dir="$1"
    [[ ! -d "$dir" ]] && return 1

    # Priority 1: Common cover names
    for name in cover folder front album art; do
        for ext in jpg jpeg png; do
            for file in "$dir"/${name}.${ext} "$dir"/${name^}.${ext} "$dir"/${name^^}.${ext}; do
                [[ -f "$file" ]] && echo "$file" && return 0
            done
        done
    done

    # Priority 2: Files with "front" in name (case insensitive)
    local cover
    cover=$(find "$dir" -maxdepth 1 -type f \( -iname "*front*" \) \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) 2>/dev/null | head -1)
    [[ -n "$cover" ]] && echo "$cover" && return 0

    # Priority 3: Any image not containing "back", "inlay", "booklet", "label", "disc", "cd"
    cover=$(find "$dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) \
        ! -iname "*back*" ! -iname "*inlay*" ! -iname "*booklet*" ! -iname "*label*" ! -iname "*disc*" ! -iname "*cd*" 2>/dev/null | head -1)
    [[ -n "$cover" ]] && echo "$cover" && return 0

    return 1
}

get_cover() {
    local file album_dir cover

    file="$(mpc current -f %file%)"
    [[ -z "$file" ]] && return 1

    album_dir="$MUSIC_DIR/$(dirname "$file")"

    # Handle CUE tracks: path ends with .cue/trackXXXX
    if [[ "$album_dir" =~ \.cue$ ]]; then
        album_dir="$(dirname "$album_dir")"
    fi

    # Try album directory first
    cover=$(find_cover_in_dir "$album_dir") && echo "$cover" && return 0

    # Try common artwork subdirectories
    for subdir in Artwork artwork Covers covers Scans scans Art art Images images; do
        cover=$(find_cover_in_dir "$album_dir/$subdir") && echo "$cover" && return 0
    done

    # Try parent directory (multi-disc albums: "Album/CD1/track.flac")
    local parent_dir="$(dirname "$album_dir")"
    if [[ "$parent_dir" != "$MUSIC_DIR" ]]; then
        cover=$(find_cover_in_dir "$parent_dir") && echo "$cover" && return 0
        for subdir in Artwork artwork Covers covers Scans scans Art art; do
            cover=$(find_cover_in_dir "$parent_dir/$subdir") && echo "$cover" && return 0
        done
    fi

    return 1
}

generate_fallback() {
    # Pick a random wallpaper and crop center square
    local wallpaper
    wallpaper=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) 2>/dev/null | shuf -n 1)
    [[ -z "$wallpaper" ]] && return 1

    # Get dimensions, crop largest centered square
    convert "$wallpaper" -gravity center -crop 1:1 +repage -resize 500x500 "$FALLBACK_PATH" 2>/dev/null
    [[ -f "$FALLBACK_PATH" ]] && echo "$FALLBACK_PATH" && return 0
    return 1
}

update_cover() {
    local cover
    cover=$(get_cover)
    if [[ -n "$cover" ]]; then
        CURRENT_COVER="$cover"
        cp "$cover" "$COVER_PATH"
        return 0
    fi

    # Fallback: random wallpaper crop
    cover=$(generate_fallback)
    if [[ -n "$cover" ]]; then
        CURRENT_COVER="fallback"
        cp "$cover" "$COVER_PATH"
        return 0
    fi

    return 1
}

# Initial cover
update_cover || exit 1
LAST_COVER="$CURRENT_COVER"

# Start imv
imv "$COVER_PATH" &
IMV_PID=$!

# Watch for changes
while kill -0 $IMV_PID 2>/dev/null; do
    mpc idle player >/dev/null 2>&1 || break
    if update_cover && [[ "$CURRENT_COVER" != "$LAST_COVER" ]]; then
        # Cover changed - restart imv
        LAST_COVER="$CURRENT_COVER"
        kill $IMV_PID 2>/dev/null
        imv "$COVER_PATH" &
        IMV_PID=$!
    fi
done
