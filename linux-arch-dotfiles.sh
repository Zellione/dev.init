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

    # Arch-specific — Hyprland ecosystem
    update_files "$env_base/arch/env/.config" "$XDG_CONFIG_HOME"
    update_files "$env_base/arch/env/.local"  "$HOME/.local"

    if [[ "${DRY_RUN:-0}" == "0" ]]; then
        systemctl --user daemon-reload 2>/dev/null || true
        systemctl --user enable hypridle.service 2>/dev/null || true
    else
        log "[DRY_RUN]: would run systemctl --user daemon-reload && systemctl --user enable hypridle.service"
    fi

    deploy_file "$env_base/common/env/.claude/settings.json" "$HOME/.claude/settings.json"
    deploy_file "$env_base/common/env/opencode/opencode.json" "$HOME/.config/opencode/opencode.json"

    # Regenerate wallust colors for current wallpaper
    _wallust_script="$HOME/.config/hypr/scripts/wallust_swww.sh"
    if [[ -f "$_wallust_script" ]]; then
        if [[ "${DRY_RUN:-0}" == "0" ]]; then
            log "regenerating wallust colors..."
            "$_wallust_script" > /dev/null 2>&1
        else
            log "[DRY_RUN]: would regenerate wallust colors via ${_wallust_script}"
        fi
    fi
    unset _wallust_script

    # Reload Hyprland config to pick up new colors
    if command -v hyprctl &>/dev/null; then
        if [[ "${DRY_RUN:-0}" == "0" ]]; then
            log "reloading Hyprland config..."
            if ! hyprctl reload 2>/dev/null; then
                log "warning: hyprctl reload failed (no running Hyprland instance?)"
            fi
        else
            log "[DRY_RUN]: would reload Hyprland config"
        fi
    fi

    deploy_file "$env_base/arch/env/.zsh_profile"     "$HOME/.zsh_profile"
    deploy_file "$env_base/arch/env/.zshrc"            "$HOME/.zshrc"
    deploy_file "$env_base/common/env/.tmux-cht-command"  "$HOME/.tmux-cht-command"
    deploy_file "$env_base/common/env/.tmux-cht-languages" "$HOME/.tmux-sessionizer"
    deploy_file "$env_base/common/env/.tmux.conf"         "$HOME/.tmux.conf"
    deploy_file "$env_base/common/env/.tmux-sessionizer"  "$HOME/.tmux-sessionizer"

    log "dotfiles deployment complete."
}

deploy_dotfiles
