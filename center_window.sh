#!/bin/sh

# Get active window ID
active_window=$(xdotool getactivewindow)

# Get the active window's coordinates
win_info=$(xwininfo -id "$active_window")
win_x=$(echo "$win_info" | awk '/Absolute upper-left X:/ { print $4 }')
win_y=$(echo "$win_info" | awk '/Absolute upper-left Y:/ { print $4 }')

# Get information about connected monitors
monitor_info=$(xrandr --query | awk '/ connected/ && /[0-9]+x[0-9]+\+[0-9]+\+[0-9]+/ {for(i=1;i<=NF;i++) if($i ~ /[0-9]+x[0-9]+\+[0-9]+\+[0-9]+/) print $i}')

# Initialize variables
monitor_width=0
monitor_height=0

# Find the monitor where the window is located
for line in $monitor_info; do
	width=$(echo "$line" | awk -F'[x+]' '{print $1}')
	height=$(echo "$line" | awk -F'[x+]' '{print $2}')
	x=$(echo "$line" | awk -F'[x+]' '{print $3}')
	y=$(echo "$line" | awk -F'[x+]' '{print $4}')

	if [ "$win_x" -ge "$x" ] && [ "$win_x" -le "$((x + width))" ] && [ "$win_y" -ge "$y" ] && [ "$win_y" -le "$((y + height))" ]; then
		monitor_width=$width
		monitor_height=$height
		break
	fi
done

# Calculate 80% of monitor dimensions
window_width=$((monitor_width * 80 / 100))
window_height=$((monitor_height * 80 / 100))

# Calculate position to center window on that monitor
pos_x=$(((monitor_width - window_width) / 2))
pos_y=$(((monitor_height - window_height) / 2))

# Apply i3 commands
i3-msg "[id=$active_window] floating enable, resize set $window_width $window_height, move position $pos_x $pos_y"
