#!/usr/bin/env bash

dry_run="0"

# colors
red="\e[31m"
yellow="\e[33m"
endcolor="\e[0m"

if [ -z "$XDG_CONFIG_HOME" ]; then
    echo "no xdg config hom"
    echo "using ~/.config"
    XDG_CONFIG_HOME=$HOME/.config
fi

if [ -z "$DEV_ENV" ]; then
    echo "env var DEV_ENV needs to be present"
    exit 1
fi

if [[ $1 == "--dry" ]]; then
    dry_run="1"
fi

log() {
    if [[ $dry_run == "1" ]]; then
        echo -e "[DRY_RUN]: $1"
    else
        echo -e "$1"
    fi
}

log "env: $DEV_ENV"

update_files() {
    log "copying over files from: $1"
    pushd "$1" &> /dev/null || exit
    (
        echo -e "\n"
        configs=$(find . -mindepth 1 -maxdepth 1 -type d)
        for c in $configs; do
            directory=${2%/}/${c#./}
            log "   removing: rm -rf $red$directory$endcolor"

            if [[ $dry_run == "0" ]]; then
                rm -rf "$directory"
            fi

            log "   copying env: cp -r $yellow$c $2$endcolor"
            if [[ $dry_run == "0" ]]; then
                cp -r "./$c" "$2"
            fi
        done
        echo -e "\n"
    )
    popd &> /dev/null || exit
}

copy() {
    log "removing: $red$2$endcolor"
    if [[ $dry_run == "0" ]]; then
        rm "$2"
    fi
    log "copying: $yellow$1$endcolor to $yellow$2$endcolor"
    if [[ $dry_run == "0" ]]; then
        cp "$1" "$2"
    fi
}

update_files "$DEV_ENV/env/.config" "$XDG_CONFIG_HOME"
update_files "$DEV_ENV/env/.local" "$HOME/.local"

copy "$DEV_ENV/env/.zsh_profile" "$HOME/.zsh_profile"
copy "$DEV_ENV/env/.zshrc" "$HOME/.zshrc"

copy "$DEV_ENV/env/.zshrc" "$HOME/.zshrc"

copy "$DEV_ENV/env/.tmux-cht-command" "$HOME/.tmux-cht-command"
copy "$DEV_ENV/env/.tmux-cht-languages" "$HOME/.tmux-sessionizer"
copy "$DEV_ENV/env/.tmux.conf" "$HOME/.tmux.conf"

copy "$DEV_ENV/env/.tmux-sessionizer" "$HOME/.tmux-sessionizer"
