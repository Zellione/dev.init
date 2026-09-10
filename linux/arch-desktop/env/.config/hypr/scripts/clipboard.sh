#!/usr/bin/env bash

selection="$(
    ~/.config/hypr/scripts/cliphist-rofi.sh |
        rofi -dmenu \
            -i \
            -p "Clipboard" \
            -display-columns 2 \
            -show-icons \
            -kb-custom-1 "Control+Delete" \
	    -kb-custom-2 "Control+Shift+Delete" \
            -theme ~/.config/rofi/themes/clipboard.rasi
)"
status=$?

case "$status" in
    0)
        # Normal selection → copy back to clipboard
        [ -z "$selection" ] && exit 0
        printf '%s' "$selection" | cliphist decode | wl-copy
        ;;

    10)
        # Delete → remove selected entry from history
        [ -z "$selection" ] && exit 0
        printf '%s' "$selection" | cliphist delete

        # Remove cached thumbnail as well.
        id="${selection%%$'\t'*}"
        rm -f "${XDG_CACHE_HOME:-$HOME/.cache}/cliphist-rofi/$id.png"

        # Reopen clipboard after deletion.
        exec "$0"
        ;;
    11)
    	confirm="$(
        printf '%s\n' "Yes" "Cancel" |
            rofi -dmenu \
                -p "Clear clipboard history?" \
                -theme ~/.config/rofi/themes/clipboard.rasi
    	)"

    	if [[ "$confirm" == "Yes" ]]; then
            cliphist wipe
            rm -rf "${XDG_CACHE_HOME:-$HOME/.cache}/cliphist-rofi"
    	fi

    	exec "$0"
    	;;

    *)
        # Escape etc.
        exit 0
        ;;
esac
