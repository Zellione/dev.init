#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}[PASS]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; FAILURES=$((FAILURES + 1)); }
info() { echo -e "${YELLOW}[INFO]${NC} $1"; }

FAILURES=0
WORKSPACE="$(cd "$(dirname "$0")/.." && pwd)"

# Ensure $HOME/.local/bin is in PATH (non-login shell compat)
export PATH="$HOME/.local/bin:$PATH"

echo "========================================="
echo "  dev.init WSL-Ubuntu — Docker Test Suite"
echo "========================================="
echo ""
info "User: $(whoami)"
info "HOME: $HOME"
info "Workspace: $WORKSPACE"
echo ""

# ── Test 1: linux-wsl-ubuntu-run.sh --dry ────────────────────────
info "Test 1: linux-wsl-ubuntu-run.sh --dry"
OUTPUT=$(bash "$WORKSPACE/linux-wsl-ubuntu-run.sh" --dry 2>&1) && {
    pass "linux-wsl-ubuntu-run.sh --dry exited 0"
} || {
    fail "linux-wsl-ubuntu-run.sh --dry exited non-zero"
}
echo ""

# ── Test 2: linux-wsl-ubuntu-dotfiles.sh --dry (no side effects) ─
info "Test 2: linux-wsl-ubuntu-dotfiles.sh --dry"
BEFORE_CONFIG=$(ls -A "$HOME/.config" 2>/dev/null | sort || true)
BEFORE_LOCAL=$(ls -A "$HOME/.local" 2>/dev/null | sort || true)

bash "$WORKSPACE/linux-wsl-ubuntu-dotfiles.sh" --dry 2>&1 && {
    pass "linux-wsl-ubuntu-dotfiles.sh --dry exited 0"
} || {
    fail "linux-wsl-ubuntu-dotfiles.sh --dry exited non-zero"
}

AFTER_CONFIG=$(ls -A "$HOME/.config" 2>/dev/null | sort || true)
AFTER_LOCAL=$(ls -A "$HOME/.local" 2>/dev/null | sort || true)

if [ "$BEFORE_CONFIG" = "$AFTER_CONFIG" ] && [ "$BEFORE_LOCAL" = "$AFTER_LOCAL" ]; then
    pass "Dry run did not modify filesystem"
else
    fail "Dry run modified filesystem (should not happen)"
fi
echo ""

# ── Test 3: linux-wsl-ubuntu-dotfiles.sh (real deploy) ───────────
info "Test 3: linux-wsl-ubuntu-dotfiles.sh (real deploy)"
bash "$WORKSPACE/linux-wsl-ubuntu-dotfiles.sh" 2>&1 && {
    pass "linux-wsl-ubuntu-dotfiles.sh exited 0"
} || {
    fail "linux-wsl-ubuntu-dotfiles.sh exited non-zero"
}
echo ""

# ── Test 4: Verify deployed files ────────────────────────────────
info "Test 4: Verify deployed files"

check_dir() {
    local desc="$1" path="$2"
    if [ -d "$path" ]; then
        pass "$desc exists: $path"
    else
        fail "$desc missing: $path"
    fi
}

check_file() {
    local desc="$1" path="$2"
    if [ -f "$path" ]; then
        pass "$desc exists: $path"
    else
        fail "$desc missing: $path"
    fi
}

# WSL-Ubuntu specific configs
check_file "Ubuntu .zshrc"          "$HOME/.zshrc"
check_file "Claude settings.json"   "$HOME/.claude/settings.json"
check_file "Opencode config"        "$HOME/.config/opencode/opencode.json"

# Common configs (shared with Arch)
check_file "Tmux config"            "$HOME/.tmux.conf"
check_file "Tmux cht command"       "$HOME/.tmux-cht-command"
check_file "Tmux cht languages"     "$HOME/.tmux-cht-languages"
check_file "Tmux sessionizer"       "$HOME/.tmux-sessionizer"

# Config dirs from common and arch
check_dir  "Neovim config"          "$HOME/.config/nvim"
check_dir  "Btop config"            "$HOME/.config/btop"
check_dir  "Fastfetch config"       "$HOME/.config/fastfetch"
check_dir  "Kitty config"           "$HOME/.config/kitty"

echo ""

# ── Test 5: Verify installed packages ────────────────────────────
info "Test 5: Verify installed packages"

check_bin() {
    local desc="$1" bin="$2"
    if command -v "$bin" &>/dev/null; then
        pass "$desc installed: $bin"
    else
        fail "$desc missing: $bin"
    fi
}

# Core tools
check_bin  "Zsh"           "zsh"
check_bin  "Tmux"          "tmux"
check_bin  "Neovim"        "nvim"
check_bin  "Git"           "git"
check_bin  "Btop"          "btop"
check_bin  "Bat"           "bat"
check_bin  "Htop"          "htop"
check_bin  "Cmake"         "cmake"
check_bin  "Curl"          "curl"
check_bin  "Ripgrep"       "rg"
check_bin  "Zip"           "zip"
check_bin  "Unzip"         "unzip"
check_bin  "Clang"         "clang"
check_bin  "Python3"       "python3"

# Build tools
check_bin  "GCC"           "gcc"
check_bin  "G++"           "g++"
check_bin  "Make"          "make"

# Dev toolchains
check_bin  "Go"            "go"
check_bin  "Rustc"         "rustc"
check_bin  "Cargo"         "cargo"
check_bin  "Node"          "node"
check_bin  "Npm"           "npm"

# vcpkg
check_bin  "vcpkg"         "vcpkg"

# Fonts
check_bin  "fc-list"       "fc-list"

# Utilities from common
check_bin  "Rsync"         "rsync"
check_bin  "Jq"            "jq"

echo ""

# ── Test 6: Font verification ────────────────────────────────────
info "Test 6: Font verification"

# Check by font file existence (bypasses fontconfig cache issues)
FIRA_FILES=$(find /usr/share/fonts -iname "*fira*" -o -iname "*firacode*" 2>/dev/null || true)
JETBRAINS_FILES=$(find /usr/share/fonts -iname "*jetbrains*" 2>/dev/null || true)

if [ -n "$FIRA_FILES" ]; then
    pass "Fira Code font files found"
else
    fail "Fira Code font files not found in /usr/share/fonts"
fi

if [ -n "$JETBRAINS_FILES" ]; then
    pass "JetBrains Mono font files found"
else
    fail "JetBrains Mono font files not found in /usr/share/fonts"
fi

echo ""

# ── Summary ──────────────────────────────────────────────────────
echo "========================================="
if [ "$FAILURES" -eq 0 ]; then
    echo -e "${GREEN}  All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}  $FAILURES test(s) failed${NC}"
    exit 1
fi
