#!/usr/bin/env bash

set -euo pipefail

dir="${HOME}/Pictures/Screenshots"
mkdir -p "$dir"

file="$dir/$(date '+%Y-%m-%d_%H-%M-%S').png"

geometry="$(slurp)" || exit 0

grim -g "$geometry" "$file"
wl-copy --type image/png < "$file"

notify-send "Screenshot" "Gespeichert und in die Zwischenablage kopiert."
