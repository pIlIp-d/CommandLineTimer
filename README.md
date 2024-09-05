# CommandLineTimer
A simple timer script with visual alarm.

(Tested on Linux with Wayland)

# Installation

Fist of all Download the Script.
Then install the following dependencies:
```
sudo apt install feh
```

# Usage

```
Usage: ./timer4.sh <time>

Time can be specified in the following formats:
  hh:mm         - Set an alarm for a specific time of day (e.g., 12:30)
  90m           - Set a timer for a duration of 90 minutes
  1h30m         - Set a timer for a duration of 1 hour and 30 minutes
  30s           - Set a timer for a duration of 30 seconds

Options:
  -h, --help    - Show this help message
```

Examples:
```
./timer.sh 2m
./timer.sh 30s
./timer.sh 1h30m
./timer.sh 10m30s
./timer.sh 11:45
./timer.sh 19:10
```
