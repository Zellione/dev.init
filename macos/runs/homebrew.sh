#!/usr/bin/env bash
set -euo pipefail

BREWFILE="$(dirname "$0")/Brewfile"

if [[ ! -f "$BREWFILE" ]]; then
    echo "Brewfile not found at $BREWFILE, skipping."
    exit 0
fi

brew bundle --file="$BREWFILE" --no-lock
