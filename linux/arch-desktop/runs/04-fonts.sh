#!/usr/bin/env bash
set -euo pipefail

# Install Nerd Fonts and system fonts

PACKAGES=(
    ttf-fira-code
    ttf-jetbrains-mono-nerd
    noto-fonts
    noto-fonts-emoji
    noto-fonts-cjk
    ttf-font-awesome
)

echo "Installing fonts..."

if pacman -Qi "${PACKAGES[@]}" &>/dev/null; then
    echo "All fonts already installed, skipping."
    exit 0
fi

sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"

echo "Fonts installed successfully."
