#!/bin/bash
# Wallust Colors for current wallpaper

cache_base="$HOME/.cache/awww/"

# Get current focused monitor
current_monitor=$(hyprctl monitors | awk '/^Monitor/{name=$2} /focused: yes/{print name}')
echo "Monitor: $current_monitor"

# Find cache file (awww may use versioned subdirs like 0.12.1/)
cache_file=$(find "$cache_base" -name "$current_monitor" -type f 2>/dev/null | head -1)
echo "Cache: $cache_file"

ln_success=false
wallpaper_path=""

if [ -n "$cache_file" ] && [ -f "$cache_file" ]; then
    wallpaper_path=$(strings "$cache_file" | tail -1)
    echo "Wallpaper: $wallpaper_path"
    if ln -sf "$wallpaper_path" "$HOME/.config/rofi/.current_wallpaper"; then
        ln_success=true
    fi
    cp -r "$wallpaper_path" "$HOME/.config/hypr/wallpaper_effects/.wallpaper_current" 2>/dev/null
fi

if [ "$ln_success" = true ]; then
    echo 'about to execute wallust'
    wallust run "$wallpaper_path" -s

    # regenerate accent colors from new palette
    python3 "$HOME/.config/hypr/scripts/generate_waybar_accents.py"
    # restart waybar to reload CSS (SIGUSR1 only toggles visibility)
    killall waybar 2>/dev/null
    # restart swaync to pick up new wallust colors
    killall swaync 2>/dev/null
    sleep 0.3
    waybar > /dev/null 2>&1 &
    swaync > /dev/null 2>&1 &
fi
