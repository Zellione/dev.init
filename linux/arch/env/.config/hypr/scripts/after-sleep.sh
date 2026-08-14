#!/usr/bin/env zsh
hyprctl dispatch 'hl.dsp.dpms({ action = "on" })'
pidof hyprlock > /dev/null || loginctl lock-session
