#!/bin/bash
# Play a random album from MPD library

# Get a random album
album=$(mpc list album | shuf -n 1)

if [ -z "$album" ]; then
    notify-send "MPD" "No albums found"
    exit 1
fi

# Clear playlist, add album, play
mpc clear
mpc find album "$album" | mpc add
mpc play

notify-send "Now Playing" "$album"
