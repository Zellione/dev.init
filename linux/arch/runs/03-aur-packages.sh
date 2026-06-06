#!/usr/bin/env bash
set -euo pipefail

# Install AUR packages via paru

if ! command -v paru &>/dev/null; then
    echo "paru not found, skipping AUR packages."
    exit 0
fi

PACKAGES=(
    wallust
    wlogout
    tokyonight-gtk-theme-git
    bibata-cursor-theme
)

echo "Installing AUR packages..."

if paru -Qi "${PACKAGES[@]}" &>/dev/null; then
    echo "All AUR packages already installed, skipping."
    exit 0
fi

paru -S --needed --noconfirm "${PACKAGES[@]}"

echo "AUR packages installed successfully."
