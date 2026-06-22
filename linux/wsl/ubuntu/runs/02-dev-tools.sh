#!/usr/bin/env bash
set -euo pipefail

# Install development toolchains for WSL-Ubuntu

echo "Installing development toolchains..."

# ── Go ─────────────────────────────────────────────────────────────
if ! command -v go &>/dev/null; then
    echo "Installing Go..."
    curl -fsSL https://go.dev/dl/go1.22.5.linux-amd64.tar.gz -o /tmp/go.tar.gz
    sudo tar -C /usr/local -xzf /tmp/go.tar.gz
    sudo ln -sf /usr/local/go/bin/go /usr/local/bin/go
    rm /tmp/go.tar.gz
    echo "Go installed."
else
    echo "Go already installed, skipping."
fi

# ── Rust ───────────────────────────────────────────────────────────
if ! command -v rustc &>/dev/null; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    echo "Rust installed."
else
    echo "Rust already installed, skipping."
fi

# Symlink Rust binaries into PATH (non-login shell compat)
if [ -f "$HOME/.cargo/bin/rustc" ] && ! command -v rustc &>/dev/null; then
    mkdir -p "$HOME/.local/bin"
    for _bin in rustc cargo rustup; do
        [ -f "$HOME/.cargo/bin/$_bin" ] && ln -sf "$HOME/.cargo/bin/$_bin" "$HOME/.local/bin/$_bin"
    done
fi

# ── nvm / Node ─────────────────────────────────────────────────────
if [ ! -d "$HOME/.nvm" ]; then
    echo "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    echo "nvm installed."
else
    echo "nvm already installed, skipping."
fi

# Source nvm and install latest Node
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    \. "$NVM_DIR/nvm.sh"
    if ! command -v node &>/dev/null; then
        echo "Installing latest Node via nvm..."
        nvm install node
        nvm alias default node
        echo "Node installed."
    else
        echo "Node already installed, skipping."
    fi
    # Symlink node/npm into PATH (non-login shell compat)
    NODE_BIN="$(nvm which node 2>/dev/null)"
    if [ -n "$NODE_BIN" ]; then
        mkdir -p "$HOME/.local/bin"
        ln -sf "$NODE_BIN" "$HOME/.local/bin/node"
        ln -sf "$(dirname "$NODE_BIN")/npm" "$HOME/.local/bin/npm"
    fi
fi

# ── vcpkg ──────────────────────────────────────────────────────────
if [ ! -d "$HOME/tools/vcpkg" ]; then
    echo "Installing vcpkg..."
    mkdir -p "$HOME/tools"
    git clone https://github.com/microsoft/vcpkg.git "$HOME/tools/vcpkg"
    bash "$HOME/tools/vcpkg/bootstrap-vcpkg.sh"
    echo "vcpkg installed."
else
    echo "vcpkg already installed, skipping."
fi

# Symlink vcpkg into PATH
if [ -f "$HOME/tools/vcpkg/vcpkg" ] && ! command -v vcpkg &>/dev/null; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$HOME/tools/vcpkg/vcpkg" "$HOME/.local/bin/vcpkg"
fi

echo "Development toolchains installed successfully."
