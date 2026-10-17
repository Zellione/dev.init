#!/usr/bin/env bash
set -euo pipefail

dir="${HOME}/Pictures/Screenshots"
mkdir -p "$dir"

file="${dir}/screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png"

monitor="$(hyprctl -j monitors | jq -r '.[] | select(.focused == true) | .name')"

[[ -n "$monitor" ]] || {
    notify-send "Screenshot" "Konnte den aktiven Monitor nicht ermitteln."
    exit 1
}

grim -o "$monitor" "$file"

if wl-copy --type image/png < "$file"; then
    notify-send "Screenshot" "Monitor ${monitor} gespeichert und in die Zwischenablage kopiert."
else
    notify-send "Screenshot" "Monitor ${monitor} gespeichert, aber Kopieren in die Zwischenablage ist fehlgeschlagen."
    exit 1
fi
