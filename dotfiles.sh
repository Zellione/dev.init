#!/usr/bin/env bash

dry_run="0"

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
        echo "[DRY_RUN]: $1"
    else
        echo "$1"
    fi
}

log "env: $DEV_ENV"

update_files() {
    log "copying over files from: $1"
    pushd "$1" &> /dev/null || exit
    (
        configs=$(find . -mindepth 1 -maxdepth 1 -type d)
        for c in $configs; do
            directory=${2%/}/${c#./}
            log "   removing: rm -rf $directory"

            if [[ $dry_run == "0" ]]; then
                rm -rf "$directory"
            fi

            log "   copying env: cp -r $c $2"
            if [[ $dry_run == "0" ]]; then
                cp -r "./$c" "$2"
            fi
        done
    )
    popd &> /dev/null || exit
}

copy() {
    log "removing: $2"
    if [[ $dry_run == "0" ]]; then
        rm "$2"
    fi
    log "copying: $1 to $2"
    if [[ $dry_run == "0" ]]; then
        cp "$1" "$2"
    fi
}

update_files "$DEV_ENV/env/.config" "$XDG_CONFIG_HOME"
update_files "$DEV_ENV"/env/.local "$HOME"/.local
