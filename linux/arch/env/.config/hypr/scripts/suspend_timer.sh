#!/usr/bin/env bash

set -u

runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
disabled_file="${runtime_dir}/hypr-suspend-timer.disabled"
idle_since_file="${runtime_dir}/hypr-suspend-timer.idle-since"
waybar_signal=8

is_enabled() {
    [[ ! -e "$disabled_file" ]]
}

refresh_waybar() {
    pkill -RTMIN+"$waybar_signal" waybar 2>/dev/null || true
}

get_timeout() {
    local config_home="${XDG_CONFIG_HOME:-${HOME}/.config}"
    local config_file="${config_home}/hypr/hypridle.conf"
    local timeout

    timeout=$(awk '
        /^listener[[:space:]]*\{/ { in_listener = 1; value = ""; next }
        in_listener && /^[[:space:]]*timeout[[:space:]]*=/ {
            value = $0
            sub(/^[^=]*=[[:space:]]*/, "", value)
            sub(/[[:space:]]*#.*/, "", value)
        }
        in_listener && /on-timeout[[:space:]]*=.*suspend_timer\.sh[[:space:]]+--suspend/ {
            print value
            exit
        }
        in_listener && /^}/ { in_listener = 0; value = "" }
    ' "$config_file" 2>/dev/null)

    if [[ "$timeout" =~ ^[0-9]+$ ]] && (( timeout > 0 )); then
        printf '%s\n' "$timeout"
    else
        printf '2700\n'
    fi
}

show_status() {
    local timeout remaining minutes now idle_since

    if is_enabled; then
        timeout=$(get_timeout)
        remaining=$timeout

        if [[ -r "$idle_since_file" ]]; then
            read -r idle_since < "$idle_since_file"
            now=$(date +%s)
            if [[ "$idle_since" =~ ^[0-9]+$ ]]; then
                remaining=$((timeout - now + idle_since))
                (( remaining < 0 )) && remaining=0
            fi
        fi

        minutes=$(((remaining + 59) / 60))
        printf '{"text":"⏱ %dm","tooltip":"Suspend timer enabled · %d seconds remaining\\nClick to disable · Super+Alt+I","class":"enabled"}\n' "$minutes" "$remaining"
    else
        printf '{"text":"⏱ OFF","tooltip":"Suspend timer disabled\\nClick to enable · Super+Alt+I","class":"disabled"}\n'
    fi
}

idle_started() {
    # swayidle calls this after one second without input; include that second.
    printf '%s\n' "$(( $(date +%s) - 1 ))" > "$idle_since_file"
    refresh_waybar
}

activity_resumed() {
    rm -f "$idle_since_file"
    refresh_waybar
}

toggle() {
    if is_enabled; then
        touch "$disabled_file"
        notify-send "Suspend timer disabled" "The system will not suspend automatically." 2>/dev/null || true
    else
        rm -f "$disabled_file"
        notify-send "Suspend timer enabled" "The system will suspend after the configured idle time." 2>/dev/null || true
    fi

    refresh_waybar
}

case "${1:---status}" in
    --status)
        show_status
        ;;
    --toggle)
        toggle
        ;;
    --idle)
        idle_started
        ;;
    --active)
        activity_resumed
        ;;
    --suspend)
        if is_enabled; then
            systemctl suspend
        fi
        ;;
    *)
        printf 'Usage: %s [--status|--toggle|--idle|--active|--suspend]\n' "$0" >&2
        exit 2
        ;;
esac
