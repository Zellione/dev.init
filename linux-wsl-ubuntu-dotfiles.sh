#!/usr/bin/env bash
# Wrapper: set DEV_ENV, source lib/dotfiles.sh, call deploy_dotfiles().
set -euo pipefail

export DRY_RUN=0
TAGS_FILTER=""
TAGS_EXCLUDE=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry) DRY_RUN=1 ;;
        --tags=*) TAGS_FILTER="${1#--tags=}" ;;
        --tags) TAGS_FILTER="$2"; shift ;;
        --exclude=*) TAGS_EXCLUDE="${1#--exclude=}" ;;
        --exclude) TAGS_EXCLUDE="$2"; shift ;;
    esac
    shift
done
export TAGS_FILTER TAGS_EXCLUDE

export DEV_ENV="$(cd "$(dirname "$0")" && pwd)/linux"
source "$(dirname "$0")/lib/dotfiles.sh"

deploy_dotfiles() {
    setup_xdg

    local env_base="${DEV_ENV%/}"

    update_files "./common/env/.config"  "$XDG_CONFIG_HOME"
    update_files "$env_base/common/env/.config" "$XDG_CONFIG_HOME"
    update_files "$env_base/common/env/.local"  "$HOME/.local" "add-only"

    # Ubuntu-specific 
    update_files "$env_base/arch/env/.config" "$XDG_CONFIG_HOME"

    deploy_file "$env_base/wsl/ubuntu/env/.claude/settings.json" "$HOME/.claude/settings.json"
    deploy_file "$env_base/common/env/opencode/opencode.json" "$HOME/.config/opencode/opencode.json"


    deploy_file "$env_base/wsl/ubuntu/env/.zshrc"            "$HOME/.zshrc"
    deploy_file "$env_base/common/env/.tmux-cht-command"  "$HOME/.tmux-cht-command"
    deploy_file "$env_base/common/env/.tmux-cht-languages" "$HOME/.tmux-sessionizer"
    deploy_file "$env_base/common/env/.tmux.conf"         "$HOME/.tmux.conf"
    deploy_file "$env_base/common/env/.tmux-sessionizer"  "$HOME/.tmux-sessionizer"

    log "dotfiles deployment complete."
}

deploy_dotfiles
