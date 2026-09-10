#!/usr/bin/env bash
set -euo pipefail

TPM_DIR="$HOME/.tmux/plugins/tpm"

if [ -d "$TPM_DIR" ]; then
    echo "TPM already installed, skipping."
    exit 0
fi

echo "Installing TPM (Tmux Plugin Manager)..."
mkdir -p "$HOME/.tmux/plugins"
git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
echo "TPM installed successfully."
