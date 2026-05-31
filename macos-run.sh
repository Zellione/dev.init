#!/usr/bin/env bash
# Wrapper: set DEV_ENV, parse args, source run.sh library, call run_scripts().
set -euo pipefail

export DEV_ENV="$(cd "$(dirname "$0")" && pwd)/macos"

DRY_RUN=0
PATTERN=""
for arg in "$@"; do
    case "$arg" in
        --dry) DRY_RUN=1 ;;
        *)     PATTERN="$arg" ;;
    esac
done

# Pass through to library (source consumes nothing if args already set)
export DRY_RUN
source "$(dirname "$0")/run.sh"
run_scripts "${PATTERN:-}"
