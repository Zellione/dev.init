# tags.sh — shared tag filter helpers for dotfiles.sh and run.sh.
# Source via lib/dotfiles.sh or lib/run.sh; do not source directly.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: source this file, do not execute it directly." >&2
    return 1 2>/dev/null || exit 1
fi

# Set defaults if not already set by wrapper
TAGS_FILTER="${TAGS_FILTER:-}"
TAGS_EXCLUDE="${TAGS_EXCLUDE:-}"

# _tag_match(item_tags, filter)
#   item_tags: comma-separated list (e.g. "hyprland,ui")
#   filter: comma-separated list to match against
#   Returns 0 if any tag in item_tags matches any tag in filter (OR logic).
_tag_match() {
    local item_tags="$1" filter="$2"
    [[ -z "$item_tags" || -z "$filter" ]] && return 1
    local ifs_old="$IFS"
    local t f
    IFS=',' read -ra f <<< "$filter"
    IFS=',' read -ra t <<< "$item_tags"
    IFS="$ifs_old"
    for _f in "${f[@]}"; do
        for _t in "${t[@]}"; do
            _f="${_f#"${_f%%[![:space:]]*}"}"
            _f="${_f%"${_f##*[![:space:]]}"}"
            _t="${_t#"${_t%%[![:space:]]*}"}"
            _t="${_t%"${_t##*[![:space:]]}"}"
            if [[ "$_t" == "$_f" ]]; then
                return 0
            fi
        done
    done
    return 1
}

# _matches_tags(item_tags)
#   Returns 0 if item passes both include and exclude tag filters.
#   - Include: if TAGS_FILTER is set, item must match at least one tag (OR).
#              If TAGS_FILTER is empty, include is a pass-through.
#   - Exclude: if TAGS_EXCLUDE is set, item must NOT match any tag.
_matches_tags() {
    local item_tags="$1"
    # Include check
    if [[ -n "$TAGS_FILTER" ]]; then
        _tag_match "$item_tags" "$TAGS_FILTER" || return 1
    fi
    # Exclude check
    if [[ -n "$TAGS_EXCLUDE" ]]; then
        ! _tag_match "$item_tags" "$TAGS_EXCLUDE" || return 1
    fi
    return 0
}

# _read_item_tags(path) — reads tag metadata for a deployable unit.
#   For a directory: checks for path/.tag file; the dir basename is
#     implicitly appended as an extra tag (e.g. ./wallust gets "wallust").
#   For a file: checks for path.tag sidecar, or a # TAGS: comment on line 3.
#   Returns the comma-separated tag string (empty if none found).
_read_item_tags() {
    local item_path="$1"
    local tags=""
    local basename=""

    if [[ -d "$item_path" ]]; then
        basename="$(basename "$item_path")"
        local tag_file="${item_path}/.tag"
        if [[ -f "$tag_file" ]]; then
            tags="$(head -1 "$tag_file" | tr -d '[:space:]')"
        fi
        # Append basename as implicit tag
        if [[ -n "$tags" ]]; then
            tags="${tags},${basename}"
        else
            tags="$basename"
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
