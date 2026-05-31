#!/usr/bin/env bash
# Wrapper: set DEV_ENV, source dotfiles.sh library, call deploy_dotfiles().
set -euo pipefail

export DEV_ENV="$(cd "$(dirname "$0")" && pwd)/macos"
source "$(dirname "$0")/dotfiles.sh" -- "$@"
deploy_dotfiles "$@"
