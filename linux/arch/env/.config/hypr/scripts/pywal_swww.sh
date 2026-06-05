#!/bin/bash
# Pywal Colors for current wallpaper

# Define the path to the swww cache directory
cache_dir="$HOME/.cache/awww/"

# Get a list of monitor outputs
monitor_outputs=($(ls "$cache_dir"))

# Initialize a flag to determine if the ln command was executed
ln_success=false

# Get first valid monitor
current_monitor=$(hyprctl -j monitors | jq -r '.[0].name')
echo $current_monitor
# Find cache file (awww may use versioned subdirs like 0.12.1/)
cache_file=$(find "$cache_dir" -name "$current_monitor" -type f 2>/dev/null | head -1)
echo $cache_file
# Check if the cache file exists for the current monitor output
if [ -n "$cache_file" ] && [ -f "$cache_file" ]; then
    # Get the wallpaper path from the cache file
    wallpaper_path=$(strings "$cache_file" | tail -1)
    echo $wallpaper_path
    # Copy the wallpaper to the location Rofi can access
    if ln -sf "$wallpaper_path" "$HOME/.config/rofi/.current_wallpaper"; then
        ln_success=true  # Set the flag to true upon successful execution
    fi
fi

# Check the flag before executing further commands
if [ "$ln_success" = true ]; then
    # execute pywal
    # wal -i "$wallpaper_path"
	echo 'about to execute wal'
    # execute pywal skipping tty and terminal changes
    wal -i "$wallpaper_path" -s -t &
fi
