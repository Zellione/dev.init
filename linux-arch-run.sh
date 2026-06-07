#!/usr/bin/env bash
# Wrapper: Linux has no setup scripts (runs/ is empty).
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

export DEV_ENV="$(cd "$(dirname "$0")" && pwd)/linux"
source "$(dirname "$0")/lib/run.sh"
run_scripts ""
