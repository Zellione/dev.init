#!/usr/bin/env bash
# Wrapper: Linux has no setup scripts (runs/ is empty).
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

export DEV_ENV="$(cd "$(dirname "$0")" && pwd)/linux/arch"
source "$(dirname "$0")/lib/run.sh"
run_scripts ""
