#!/bin/bash
# Track split orientation by writing to a file

SPLIT_FILE="/tmp/sway-split-mode"

if [ "$1" = "v" ]; then
    echo "vertical" > "$SPLIT_FILE"
    swaymsg split v
elif [ "$1" = "h" ]; then
    echo "horizontal" > "$SPLIT_FILE"
    swaymsg split h
fi
