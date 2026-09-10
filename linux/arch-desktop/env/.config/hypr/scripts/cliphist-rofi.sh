#!/usr/bin/env bash
set -euo pipefail

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/cliphist-rofi"
mkdir -p "$cache_dir"

while IFS= read -r line; do
    id="${line%%$'\t'*}"
    text="${line#*$'\t'}"

    if [[ "$text" == \[\[\ binary\ data* ]]; then
        thumb="$cache_dir/$id.png"

        if [[ ! -f "$thumb" ]]; then
            printf '%s\n' "$line" | cliphist decode > "$thumb" 2>/dev/null || {
                rm -f "$thumb"
                continue
            }
        fi

        printf '%s\0icon\x1f%s\n' "$line" "$thumb"
    else
        printf '%s\n' "$line"
    fi
done < <(cliphist list)
