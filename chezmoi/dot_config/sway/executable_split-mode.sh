#!/bin/bash
# Simple script to show current split orientation

while true; do
    # Get the focused container's split orientation
    split=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | .layout' 2>/dev/null)

    case "$split" in
        splith)
            echo "◫ H"  # Horizontal split
            ;;
        splitv)
            echo "⬒ V"  # Vertical split
            ;;
        *)
            echo "▣"    # No split or other layout
            ;;
    esac

    sleep 1
done
