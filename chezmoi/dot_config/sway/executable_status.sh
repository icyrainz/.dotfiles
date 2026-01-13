#!/bin/bash

SPLIT_FILE="/tmp/sway-split-mode"

# Initialize if doesn't exist
if [ ! -f "$SPLIT_FILE" ]; then
    echo "vertical" > "$SPLIT_FILE"
fi

while true; do
    # Read current split mode from file
    if [ -f "$SPLIT_FILE" ]; then
        orientation=$(cat "$SPLIT_FILE")
        case "$orientation" in
            horizontal) split_text="H" ;;
            vertical) split_text="V" ;;
            *) split_text="?" ;;
        esac
    else
        split_text="?"
    fi

    # Battery status
    battery_status=""
    if [ -d /sys/class/power_supply/BAT1 ]; then
        capacity=$(cat /sys/class/power_supply/BAT1/capacity)
        status=$(cat /sys/class/power_supply/BAT1/status)

        case "$status" in
            Charging) battery_icon="+" ;;
            Discharging) battery_icon="-" ;;
            Full) battery_icon="=" ;;
            *) battery_icon="?" ;;
        esac

        battery_status="$battery_icon $capacity% | "
    fi

    date_time=$(date +'%Y-%m-%d %H:%M:%S')
    echo "$split_text | ${battery_status}$date_time"
    sleep 0.2
done
