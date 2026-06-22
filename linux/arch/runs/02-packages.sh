#!/usr/bin/env bash
set -euo pipefail

# Install all pacman packages for Hyprland setup

PACKAGES=(
    # Core Hyprland + Wayland
    hyprland
    hyprlock
    hypridle
    xdg-desktop-portal-hyprland
    xdg-desktop-portal
    xdg-utils

    # Terminal + File Manager
    kitty
    thunar
    tmux
    yazi
    fd

    # Editor
    neovim
    tree-sitter-cli

    # Productivity
    tldr

    # Status Bar + Menus + Lock
    waybar
    yad
    swaync
    libnotify

    # Screenshots + Clipboard
    grim
    slurp
    swappy
    wl-clipboard
    cliphist

    # Audio
    pipewire
    pipewire-pulse
    pamixer
    pavucontrol
    cava
    mpv
    playerctl

    # Brightness + System
    brightnessctl
    btop
    jq
    curl
    polkit
    rsync

    # Qt/GTK Theming
    qt5ct
    qt6ct
    gtk3
    gtk4

    # Networking + Bluetooth
    networkmanager
    blueman

    # Python
    python
    python-requests
    uv

    # Docker + container management
    docker
    docker-buildx
    docker-compose
    lazydocker

    # Sound theme
    sound-theme-freedesktop

    # System monitoring
    gnome-system-monitor
    nvtop
    fastfetch
)

echo "Installing pacman packages..."

if pacman -Qi "${PACKAGES[@]}" &>/dev/null; then
    echo "All pacman packages already installed, skipping."
    exit 0
fi

sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"

echo "Pacman packages installed successfully."
