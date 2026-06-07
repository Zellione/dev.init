#!/usr/bin/env bash
# Wrapper: set DEV_ENV, parse args, source lib/run.sh, call run_scripts().
set -euo pipefail

export DEV_ENV="$(cd "$(dirname "$0")" && pwd)/macos"

export DRY_RUN=0
TAGS_FILTER=""
TAGS_EXCLUDE=""
PATTERN=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry) DRY_RUN=1 ;;
        --tags=*) TAGS_FILTER="${1#--tags=}" ;;
        --tags) TAGS_FILTER="$2"; shift ;;
        --exclude=*) TAGS_EXCLUDE="${1#--exclude=}" ;;
        --exclude) TAGS_EXCLUDE="$2"; shift ;;
        *)     PATTERN="$1" ;;
    esac
    shift
done
export TAGS_FILTER TAGS_EXCLUDE

source "$(dirname "$0")/lib/run.sh"
run_scripts "${PATTERN:-}"
