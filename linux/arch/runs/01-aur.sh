#!/usr/bin/env bash
set -euo pipefail

# Install paru (AUR helper) — must run before 03-aur-packages.sh

if command -v paru &>/dev/null; then
    echo "paru already installed, skipping."
    exit 0
fi

echo "Installing paru..."

# Install base-devel if not present
if ! pacman -Qi base-devel &>/dev/null; then
    sudo pacman -S --needed --noconfirm base-devel
fi

# Install git if not present
if ! pacman -Qi git &>/dev/null; then
    sudo pacman -S --needed --noconfirm git
fi

PARU_DIR="$(mktemp -d)"
trap 'rm -rf "$PARU_DIR"' EXIT

git clone https://aur.archlinux.org/paru.git "$PARU_DIR/paru"
pushd "$PARU_DIR/paru"
makepkg -si --noconfirm
popd

echo "paru installed successfully."
