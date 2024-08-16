#!/bin/bash

# Function to convert time format to seconds
convert_to_seconds() {
    local time_str="$1"
    local total_seconds=0

    # Default to minutes if no unit is provided
    [[ ! "$time_str" =~ [hms] ]] && time_str="${time_str}m"

    # Extract hours, minutes, and seconds from the input
    if [[ "$time_str" =~ ([0-9]+)h ]]; then
        total_seconds=$((total_seconds + ${BASH_REMATCH[1]} * 3600))
    fi
    if [[ "$time_str" =~ ([0-9]+)m ]]; then
        total_seconds=$((total_seconds + ${BASH_REMATCH[1]} * 60))
    fi
    if [[ "$time_str" =~ ([0-9]+)s ]]; then
        total_seconds=$((total_seconds + ${BASH_REMATCH[1]}))
    fi

    echo $total_seconds
}

# Check if an argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <time>"
    exit 1
fi

# Read the time input
input_time="$1"
# Convert the input time to seconds
seconds=$(convert_to_seconds "$input_time")

# Validate that the conversion was successful and resulted in a positive number
if [ "$seconds" -le 0 ] 2>/dev/null; then
    echo "Please provide a valid time format (e.g., 12s, 1m, 1h, 1m30s). If no unit is given, it defaults to minutes."
    exit 1
fi

# Start the countdown and display time remaining in the console
for i in $(seq $seconds -1 0); do
    echo -ne "Time remaining: $((i / 60))m $((i % 60))s\033[0K\r"
    sleep 1
done


# create image for overlay
IMAGE_PATH="/tmp/timer_overlay.png"
resolution=$(xrandr | grep '*' | awk '{print $1}')

convert -size "$resolution" xc:"#ddee11" "$IMAGE_PATH"

# Show the image overlay as an alarm using feh
feh --fullscreen --hide-pointer --slideshow-delay 0 $IMAGE_PATH &
