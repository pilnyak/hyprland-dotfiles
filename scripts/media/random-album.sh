#!/bin/bash
# Play a random album from MPD library (by directory, not tag)

# Get a random album, find one track, get its directory
album=$(mpc list album | shuf -n 1)

if [ -z "$album" ]; then
    notify-send "MPD" "No albums found"
    exit 1
fi

# Get a track from this album and extract its directory
track=$(mpc find album "$album" | head -1)
if [ -z "$track" ]; then
    notify-send "MPD" "No tracks found for: $album"
    exit 1
fi

album_dir=$(dirname "$track")

# Clear playlist, add all tracks from directory, play
mpc clear
mpc find base "$album_dir" | mpc add
mpc play

notify-send "Now Playing" "$(basename "$album_dir")"
