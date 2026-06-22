#!/bin/bash

SCRIPTSDIR=$HOME/.config/hypr/scripts

file_exists() {
  if [ -e "$1" ]; then
    return 0
  else
    return 1
  fi
}

# Kill already running processes
_ps=(waybar rofi swaync)
for _prs in "${_ps[@]}"; do
    if pidof "${_prs}" >/dev/null; then
        pkill "${_prs}"
    fi
done

 sleep 0.3
# Relaunch waybar
 waybar &

 exit 0
