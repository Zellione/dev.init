#!/usr/bin/env bash
set -euo pipefail

choice="$(
    printf '%s\n' \
        "󰌾  Lock" \
        "󰍃  Logout" \
        "󰜉  Reboot" \
        "󰐥  Shutdown" \
    | rofi -dmenu \
        -i \
        -p "Power" \
        -theme ~/.config/rofi/themes/power.rasi
)"

case "$choice" in
    *"Lock")
        loginctl lock-session
        ;;
    *"Logout")
        uwsm stop
        ;;
    *"Reboot")
        systemctl reboot
        ;;
    *"Shutdown")
        systemctl poweroff
        ;;
esac
