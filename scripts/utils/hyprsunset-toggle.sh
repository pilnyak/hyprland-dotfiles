#!/bin/bash
# Toggle hyprsunset (night mode)
# Default: 4500K warm temperature

TEMP="${1:-4500}"

if pgrep -x hyprsunset > /dev/null; then
    pkill hyprsunset
    notify-send "Hyprsunset" "Night mode off" -t 1500
else
    hyprsunset -t "$TEMP" &
    notify-send "Hyprsunset" "Night mode on (${TEMP}K)" -t 1500
fi
