#!/usr/bin/env bash
set -euo pipefail

dir="${HOME}/Pictures/Screenshots"
mkdir -p "$dir"

file="$dir/$(date '+%Y-%m-%d_%H-%M-%S').png"

geometry="$(slurp)" || exit 0

grim -g "$geometry" "$file"

if wl-copy --type image/png < "$file"; then
    notify-send "Screenshot" "Bereich gespeichert und in die Zwischenablage kopiert."
else
    notify-send "Screenshot" "Bereich gespeichert, aber Kopieren in die Zwischenablage ist fehlgeschlagen."
    exit 1
fi
