#!/usr/bin/env bash
# Wrapper: set DEV_ENV, source dotfiles.sh library, call deploy_dotfiles().
set -euo pipefail

export DRY_RUN=0
for _arg in "$@"; do
    if [[ "$_arg" == "--dry" ]]; then DRY_RUN=1; fi
done
unset _arg

export DEV_ENV="$(cd "$(dirname "$0")" && pwd)/linux"
source "$(dirname "$0")/dotfiles.sh"

deploy_dotfiles() {
    setup_xdg

    local env_base="${DEV_ENV%/}"

    update_files "./common/env/.config"  "$XDG_CONFIG_HOME"
    update_files "$env_base/common/env/.config" "$XDG_CONFIG_HOME"
    update_files "$env_base/common/env/.local"  "$HOME/.local"

    deploy_file "$env_base/common/env/.claude/settings.json" "$HOME/.claude/settings.json"
    deploy_file "$env_base/common/env/opencode/opencode.json" "$HOME/.config/opencode/opencode.json"

    # deploy_file "$env_base/env/.zsh_profile"     "$HOME/.zsh_profile"
    # deploy_file "$env_base/env/.zshrc"            "$HOME/.zshrc"
    # deploy_file "$env_base/env/.tmux-cht-command"  "$HOME/.tmux-cht-command"
    # deploy_file "$env_base/env/.tmux-cht-languages" "$HOME/.tmux-sessionizer"
    # deploy_file "$env_base/env/.tmux.conf"         "$HOME/.tmux.conf"
    # deploy_file "$env_base/env/.tmux-sessionizer"  "$HOME/.tmux-sessionizer"

    log "dotfiles deployment complete."
}

deploy_dotfiles
