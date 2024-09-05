#!/bin/bash

usage() {
    echo "Usage: $0 <time>"
    echo
    echo "Time can be specified in the following formats:"
    echo "  hh:mm         - Set an alarm for a specific time of day (e.g., 12:30)"
    echo "  90m           - Set a timer for a duration of 90 minutes"
    echo "  1h30m         - Set a timer for a duration of 1 hour and 30 minutes"
    echo "  30s           - Set a timer for a duration of 30 seconds"
    echo
    echo "Options:"
    echo "  -h, --help    - Show this help message"
}

convert_to_seconds() {
    local time_str="$1"
    local total_seconds=0

    # Check for hh:mm format
    if [[ "$time_str" =~ ^([0-9]{1,2}):([0-9]{2})$ ]]; then
        local hours=${BASH_REMATCH[1]}
        local minutes=${BASH_REMATCH[2]}

        # Validate hours and minutes
        if (( hours < 0 || hours > 23 )); then
            echo "Invalid hour: $hours. Must be between 0 and 23." >&2
            return 1
        fi
        if (( minutes < 0 || minutes > 59 )); then
            echo "Invalid minute: $minutes. Must be between 0 and 59." >&2
            return 1
        fi

        # Get the current time in seconds since the epoch
        local current_time=$(date +%s)
        
        # Calculate the alarm time in seconds since the epoch for today
        local alarm_time=$(date -d "$(date +%Y-%m-%d) $hours:$minutes" +%s)

        # If the alarm time has already passed today, set it for tomorrow
        if [ "$alarm_time" -le "$current_time" ]; then
            alarm_time=$((alarm_time + 86400))  # Add 24 hours in seconds
        fi

        # Calculate the total seconds until the alarm
        total_seconds=$((alarm_time - current_time))
    else
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
    fi

    # Ensure total_seconds is positive
    if [ "$total_seconds" -le 0 ]; then
        echo "Invalid time duration. Please provide a positive time." >&2
        return 1
    fi

    echo $total_seconds
}

# Check if an argument is provided
if [ "$#" -ne 1 ]; then
    usage
    exit 1
fi

# Check for help option
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    usage
    exit 0
fi

input_time="$1"
seconds=$(convert_to_seconds "$input_time")

if [ "$?" -ne 0 ]; then
    exit 1
fi

# Start the countdown and display time remaining in the console
if [[ "$input_time" =~ : ]]; then
    echo "Alarm set for $input_time."
else
    echo "Timer started for $input_time."
fi

for i in $(seq $seconds -1 0); do
    if [[ "$input_time" =~ : ]]; then
        echo -ne "Time remaining: $((i / 3600))h $((i / 60 % 60))m $((i % 60))s\033[0K\r"
    else
        echo -ne "Time remaining: $((i / 3600))h $((i / 60 % 60))m $((i % 60))s\033[0K\r"
    fi
    sleep 1
done

# Create image for overlay
IMAGE_PATH="/tmp/timer_overlay.png"
resolution=$(xrandr | grep '*' | awk '{print $1}')

convert -size "$resolution" xc:"#ddee11" "$IMAGE_PATH"

# Show the image overlay as an alarm using feh
feh --fullscreen --hide-pointer --slideshow-delay 0 $IMAGE_PATH &
