#!/bin/bash
# Floating cover art viewer for MPD
# Copies cover to fixed path, restarts imv on change

MUSIC_DIR="/mnt/AJI/Music"
COVER_PATH="/tmp/mpd_cover_current.jpg"

get_cover() {
    file="$(mpc current -f %file%)"
    [[ -z "$file" ]] && return 1

    album_dir="$MUSIC_DIR/$(dirname "$file")"

    # Check common names first
    for name in cover.jpg cover.png folder.jpg folder.png album.jpg album.png art.jpg art.png Cover.jpg Cover.png; do
        if [[ -f "$album_dir/$name" ]]; then
            echo "$album_dir/$name"
            return 0
        fi
    done

    # Fallback: any jpg/png in directory
    cover=$(find "$album_dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" \) ! -name "*back*" | head -1)
    if [[ -n "$cover" ]]; then
        echo "$cover"
        return 0
    fi

    return 1
}

update_cover() {
    cover=$(get_cover)
    if [[ -n "$cover" ]]; then
        cp "$cover" "$COVER_PATH"
        return 0
    fi
    return 1
}

# Initial cover
update_cover || exit 1

# Start imv
imv "$COVER_PATH" &
IMV_PID=$!

# Watch for changes
while kill -0 $IMV_PID 2>/dev/null; do
    mpc idle player >/dev/null 2>&1 || break
    if update_cover; then
        # Kill and restart imv to show new cover
        kill $IMV_PID 2>/dev/null
        imv "$COVER_PATH" &
        IMV_PID=$!
    fi
done
