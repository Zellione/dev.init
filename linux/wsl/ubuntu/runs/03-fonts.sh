#!/usr/bin/env bash
set -euo pipefail

# Install fonts for WSL-Ubuntu

echo "Installing fonts..."

# Ensure fontconfig is available (provides fc-list, fc-cache)
sudo apt-get install -y fontconfig

# ── Fira Code ───────────────────────────────────────────────────────
sudo apt-get install -y fonts-firacode

# ── JetBrains Mono (Nerd Font) ─────────────────────────────────────
if fc-list -q "JetBrainsMono Nerd Font" 2>/dev/null; then
    echo "JetBrains Mono already installed, skipping."
else
    echo "Installing JetBrains Mono Nerd Font..."
    TEMP_DIR=$(mktemp -d)
    curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip \
        -o "$TEMP_DIR/JetBrainsMono.zip"
    unzip -o -q "$TEMP_DIR/JetBrainsMono.zip" -d /usr/share/fonts/truetype/jetbrains-mono
    fc-cache -f
    rm -rf "$TEMP_DIR"
    echo "JetBrains Mono installed."
fi

echo "Fonts installed successfully."
