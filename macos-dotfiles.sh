#!/usr/bin/env bash
# Wrapper: set DEV_ENV, source lib/dotfiles.sh, call deploy_dotfiles().
set -euo pipefail

export DRY_RUN=0
TAGS_FILTER=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry) DRY_RUN=1 ;;
        --tags=*) TAGS_FILTER="${1#--tags=}" ;;
        --tags) TAGS_FILTER="$2"; shift ;;
    esac
    shift
done
export TAGS_FILTER

export DEV_ENV="$(cd "$(dirname "$0")" && pwd)/macos"
source "$(dirname "$0")/lib/dotfiles.sh"

deploy_dotfiles() {
    setup_xdg

    local env_base="${DEV_ENV%/}"

    update_files "./common/env/.config"  "$XDG_CONFIG_HOME"
    update_files "$env_base/env/.config" "$XDG_CONFIG_HOME"
    update_files "$env_base/env/.local"  "$HOME/.local"

    deploy_file "$env_base/env/.zsh_profile"     "$HOME/.zsh_profile"
    deploy_file "$env_base/env/.zshrc"            "$HOME/.zshrc"
    deploy_file "$env_base/env/.tmux-cht-command"  "$HOME/.tmux-cht-command"
    deploy_file "$env_base/env/.tmux-cht-languages" "$HOME/.tmux-sessionizer"
    deploy_file "$env_base/env/.tmux.conf"         "$HOME/.tmux.conf"
    deploy_file "$env_base/env/.tmux-sessionizer"  "$HOME/.tmux-sessionizer"

    log "dotfiles deployment complete."
}

deploy_dotfiles
