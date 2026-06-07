# dotfiles.sh — macOS/Linux config deployment library.
# Source via macos-dotfiles.sh or linux-dotfiles.sh; do not execute directly.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: source this file, do not execute it directly." >&2
    return 1 2>/dev/null || exit 1
fi

if [ -z "${DEV_ENV:-}" ]; then
    echo "Error: DEV_ENV must be set before sourcing dotfiles.sh" >&2
    return 1 2>/dev/null || exit 1
fi

source "$(dirname "${BASH_SOURCE[0]}")/tags.sh"

# Colors
RED=$'\e[31m'
YELLOW=$'\e[33m'
ENCOLOR=$'\e[0m'

log() {
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        echo -e "[DRY_RUN]: $1"
    else
        echo -e "$1"
    fi
}

setup_xdg() {
    if [ -z "${XDG_CONFIG_HOME:-}" ]; then
        XDG_CONFIG_HOME="$HOME/.config"
        export XDG_CONFIG_HOME
    fi
}

# this method should probably fail silently
update_files() {
    local src_dir="$1"
    local dest_dir="${2%/}"

    log "syncing files from: ${src_dir}"
    pushd "$src_dir" &>/dev/null || return 1

    echo ""
    local configs c target item_tags
    configs=$(find . -mindepth 1 -maxdepth 1 -type d)
    for c in $configs; do
        item_tags=$(_read_item_tags "./$c")
        if ! _matches_tags "$item_tags"; then
            log "   filtered (tags: ${item_tags:-none}): ${YELLOW}${c}${ENCOLOR}"
            continue
        fi
        target="$dest_dir/${c#./}"
        log "   syncing: ${YELLOW}${c}${ENCOLOR} -> ${target}"
        if [[ "${DRY_RUN:-0}" == "0" ]]; then
            mkdir -p "$target"
            rsync -a --delete "./$c/" "$target/"
        fi
    done
    echo ""
    popd &>/dev/null || return 1
}

deploy_file() {
    local src="$1"
    local dest="$2"

    local item_tags
    item_tags=$(_read_item_tags "$src")
    if ! _matches_tags "$item_tags"; then
        log "   filtered (tags: ${item_tags:-none}): ${YELLOW}${src}${ENCOLOR}"
        return 0
    fi

    if [[ -e "${src}" ]]; then
        log "removing: ${RED}${dest}${ENCOLOR}"
        if [[ "${DRY_RUN:-0}" == "0" ]]; then rm -f "$dest"; fi
        log "copying: ${YELLOW}${src}${ENCOLOR} -> ${dest}${ENCOLOR}"
        if [[ "${DRY_RUN:-0}" == "0" ]]; then
            mkdir -p "$(dirname "$dest")"
            cp "${src}" "${dest}"
        fi
    else
        log "skipping (not found): ${src}"
    fi
}
