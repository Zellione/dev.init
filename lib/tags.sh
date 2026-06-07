# tags.sh — shared tag filter helpers for dotfiles.sh and run.sh.
# Source via lib/dotfiles.sh or lib/run.sh; do not source directly.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: source this file, do not execute it directly." >&2
    return 1 2>/dev/null || exit 1
fi

# Set default if not already set by wrapper
TAGS_FILTER="${TAGS_FILTER:-}"

# _matches_tags(item_tags)
#   item_tags: comma-separated list (e.g. "hyprland,ui")
#   Returns 0 if any tag in item_tags matches any tag in TAGS_FILTER (OR logic).
#   If TAGS_FILTER is empty/unset, returns 0 (include everything — backward compat).
_matches_tags() {
    local item_tags="$1"
    if [[ -z "$TAGS_FILTER" ]]; then
        return 0
    fi
    if [[ -z "$item_tags" ]]; then
        return 1
    fi
    local ifs_old="$IFS"
    local t tf
    IFS=',' read -ra tf <<< "$TAGS_FILTER"
    IFS=',' read -ra t <<< "$item_tags"
    IFS="$ifs_old"
    for _tf in "${tf[@]}"; do
        for _t in "${t[@]}"; do
            _tf="${_tf#"${_tf%%[![:space:]]*}"}"
            _tf="${_tf%"${_tf##*[![:space:]]}"}"
            _t="${_t#"${_t%%[![:space:]]*}"}"
            _t="${_t%"${_t##*[![:space:]]}"}"
            if [[ "$_t" == "$_tf" ]]; then
                return 0
            fi
        done
    done
    return 1
}

# _read_item_tags(path) — reads tag metadata for a deployable unit.
#   For a directory: checks for path/.tag file.
#   For a file: checks for path.tag sidecar, or a # TAGS: comment on line 3.
#   Returns the comma-separated tag string (empty if none found).
_read_item_tags() {
    local item_path="$1"
    local tags=""

    if [[ -d "$item_path" ]]; then
        local tag_file="${item_path}/.tag"
        if [[ -f "$tag_file" ]]; then
            tags="$(head -1 "$tag_file" | tr -d '[:space:]')"
        fi
    elif [[ -f "$item_path" ]]; then
        local sidecar="${item_path}.tag"
        if [[ -f "$sidecar" ]]; then
            tags="$(head -1 "$sidecar" | tr -d '[:space:]')"
        else
            tags="$(head -3 "$item_path" | grep -i '^# TAGS:' | sed 's/^# TAGS:[[:space:]]*//i' | tr -d '[:space:]')"
        fi
    fi

    echo "$tags"
}
