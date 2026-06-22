#!/usr/bin/env bash
set -euo pipefail

# Install apt packages for WSL-Ubuntu setup

PACKAGES=(
    zsh
    tmux
    neovim
    git
    build-essential
    btop
    bat
    htop
    cmake
    curl
    ripgrep
    zip
    unzip
    clang
    python3
    rsync
    jq
    tealdeer
)

echo "Installing apt packages..."

if dpkg -s "${PACKAGES[@]}" >/dev/null 2>&1; then
    echo "All packages already installed, skipping."
    exit 0
fi

sudo apt-get update
sudo apt-get install -y "${PACKAGES[@]}"

# bat on Ubuntu installs as batcat due to a conflict — symlink for convenience
if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
    sudo ln -sf /usr/bin/batcat /usr/local/bin/bat
fi

echo "Apt packages installed successfully."
