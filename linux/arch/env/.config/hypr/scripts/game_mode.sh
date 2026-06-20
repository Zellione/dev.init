#!/bin/bash
# Game Mode. Turning off all animations

notif="$HOME/.config/swaync/images/bell.png"
SCRIPTSDIR="$HOME/.config/hypr/scripts"


HYPRGAMEMODE=$(hyprctl -j getoption animations:enabled | jq '.bool')
if [ "$HYPRGAMEMODE" = "true" ] ; then
    hyprctl eval 'hl.config({ animations = { enabled = 0 }, decoration = { drop_shadow = 0, blur = { passes = 0 }, rounding = 0 }, general = { gaps_in = 0, gaps_out = 0, border_size = 1 } })'
    swww kill
    notify-send -e -u low -i "$notif" "gamemode enabled. All animations off"
    exit
else
	hyprctl eval 'hl.config({ animations = { enabled = 1 }, decoration = { drop_shadow = 1, blur = { passes = 2 }, rounding = 8 }, general = { gaps_in = 4, gaps_out = 8, border_size = 2 } })'
	swww init && swww img "$HOME/.config/rofi/.current_wallpaper"
	sleep 0.1
	${SCRIPTSDIR}/wallust_swww.sh
	sleep 0.5
	${SCRIPTSDIR}/refresh.sh
    notify-send -e -u normal -i "$notif" "gamemode disabled. All animations normal"
	exit
fi
hyprctl reload
