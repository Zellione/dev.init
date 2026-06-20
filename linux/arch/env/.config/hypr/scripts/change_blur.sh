#!/bin/bash
# Script for changing blurs on the fly

notify="$HOME/.config/swaync/images/bell.png"

STATE=$(hyprctl -j getoption decoration:blur:passes | jq ".int")

if [ "${STATE}" == "2" ]; then
	hyprctl -r eval 'hl.config({ decoration = { blur = { passes = 1, size = 2 } } })'
 	notify-send -e -u low -i "$notify" "Less blur"
else
	hyprctl -r eval 'hl.config({ decoration = { blur = { passes = 2, size = 5 } } })'
  	notify-send -e -u low -i "$notify" "Normal blur"
fi
