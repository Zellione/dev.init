#!/bin/bash
# This is for changing kb_layouts. Set kb_layouts in $settings_file

layout_f="$HOME/.cache/kb_layout"
settings_file="$HOME/.config/hypr/input.lua"
notif="$HOME/.config/swaync/images/bell.png"

# Check if ~/.cache/kb_layout exists and create it with a default layout from Settings.conf if not found
if [ ! -f "$layout_f" ]; then
  default_layout=$(grep -oP 'kb_layout\s*=\s*"\K[^",]+' "$settings_file" 2>/dev/null)
  if [ -z "$default_layout" ]; then
    default_layout="us" # Default to 'us' layout if not found
  fi
  echo "$default_layout" > "$layout_f"
fi

current_layout=$(cat "$layout_f")

# Read keyboard layout settings from input.lua
if [ -f "$settings_file" ]; then
  kb_layout_line=$(grep -oP 'kb_layout\s*=\s*"\K[^"]+' "$settings_file")
  IFS=',' read -ra layout_mapping <<< "$kb_layout_line"
fi

layout_count=${#layout_mapping[@]}

# Find the index of the current layout in the mapping
for ((i = 0; i < layout_count; i++)); do
  if [ "$current_layout" == "${layout_mapping[i]}" ]; then
    current_index=$i
    break
  fi
done

# Calculate the index of the next layout
next_index=$(( (current_index + 1) % layout_count ))
new_layout="${layout_mapping[next_index]}"

# Update the keyboard layout
hyprctl keyword input:kb_layout "$new_layout"
echo "$new_layout" > "$layout_f"

# Notification for the new keyboard layout
notify-send -u low -i "$notif" "new KB_Layout: $new_layout"
