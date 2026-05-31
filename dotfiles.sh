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

# Parse --dry from library-level args (only meaningful when source'd)
_DRY_SET="${DRY_RUN:-0}"
for _arg in "$@"; do
    if [[ "$_arg" == "--dry" ]]; then DRY_RUN=1; fi
done
unset _arg
export DRY_RUN="${DRY_RUN:-$_DRY_SET}"

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

update_files() {
    local src_dir="$1"
    local dest_dir="${2%/}"

    log "copying over files from: ${src_dir}"
    pushd "$src_dir" &>/dev/null || return 1

    echo ""
    local configs c target
    configs=$(find . -mindepth 1 -maxdepth 1 -type d)
    for c in $configs; do
        target="$dest_dir/${c#./}"
        log "   removing: rm -rf ${RED}${target}${ENCOLOR}"
        if [[ "${DRY_RUN:-0}" == "0" ]]; then rm -rf "$target"; fi

        log "   copying: ${YELLOW}${c}${ENCOLOR} -> $dest_dir/"
        if [[ "${DRY_RUN:-0}" == "0" ]]; then cp -r "./$c" "$dest_dir"; fi
    done
    echo ""
    popd &>/dev/null || return 1
}

deploy_file() {
    local src="$1"
    local dest="$2"

    if [[ -e "${src}" ]]; then
        log "removing: ${RED}${dest}${ENCOLOR}"
        if [[ "${DRY_RUN:-0}" == "0" ]]; then rm -f "$dest"; fi
        log "copying: ${YELLOW}${src}${ENCOLOR} -> ${dest}${ENCOLOR}"
        if [[ "${DRY_RUN:-0}" == "0" ]]; then cp "${src}" "${dest}"; fi
    else
        log "skipping (not found): ${src}"
    fi
}

# Called by wrapper after sourcing to perform the actual deployment
deploy_dotfiles() {
    setup_xdg

    local env_base="${DEV_ENV%/}"

    update_files "$env_base/env/.config" "$XDG_CONFIG_HOME"
    update_files "$env_base/env/.local"   "$HOME/.local"

    deploy_file "$env_base/env/.zsh_profile"     "$HOME/.zsh_profile"
    deploy_file "$env_base/env/.zshrc"            "$HOME/.zshrc"
    deploy_file "$env_base/env/.tmux-cht-command"  "$HOME/.tmux-cht-command"
    deploy_file "$env_base/env/.tmux-cht-languages" "$HOME/.tmux-sessionizer"
    deploy_file "$env_base/env/.tmux.conf"         "$HOME/.tmux.conf"
    deploy_file "$env_base/env/.tmux-sessionizer"  "$HOME/.tmux-sessionizer"

    log "dotfiles deployment complete."
}
