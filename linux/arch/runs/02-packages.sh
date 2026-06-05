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

    # Editor
    neovim

    # Status Bar + Menus + Lock
    waybar
    rofi
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
    kvantum
    gtk3
    gtk4

    # Networking + Bluetooth
    networkmanager
    blueman

    # Python
    python
    python-requests

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
