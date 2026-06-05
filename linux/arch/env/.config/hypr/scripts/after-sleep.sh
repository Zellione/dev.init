#!/usr/bin/env zsh
hyprctl dispatch dpms on
pidof hyprlock > /dev/null || loginctl lock-session
