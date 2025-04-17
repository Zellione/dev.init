#!/usr/bin/env bash

if [ -z "$DEV_ENV" ]; then
    echo "env var DEV_ENV needs to be present"
    exit 1
fi

export DEV_ENV="$DEV_ENV"

dry_run="0"

while [[ $# -gt 0 ]]; do
    echo "ARG: \"$1\""
    if [[ "$1" == "--dry" ]]; then
        dry_run="1"
    else
        grep="$1"
    fi
    shift
done

log() {
    if [[ $dry_run == "1" ]]; then
        echo "[DRY_RUN]: $1"
    else
        echo "$1"
    fi
}

log "RUN: env: $DEV_ENV -- grep: $grep"

if [[ $DEV_ENV == "macos" ]]; then
    scripts=`find $DEV_ENV/runs -mindepth 1 -maxdepth 1 -executable`
else
    scripts=`find $DEV_ENV/runs -mindepth 1 -maxdepth 1 -perm +111`
fi

for s in $scripts; do
    if echo "$s" | grep -vq "$grep"; then
        log "grep \"$grep\" filtered out $s"
        continue
    fi

    log "running script: $s"

    if [[ $dry_run == "0" ]]; then
        $s
    fi
done
