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

echo "========================================="
echo "  dev.init Linux Arch — Docker Test Suite"
echo "========================================="
echo ""
info "User: $(whoami)"
info "HOME: $HOME"
info "Workspace: $WORKSPACE"
echo ""

# ── Test 1: linux-arch-run.sh --dry ──────────────────────────────
info "Test 1: linux-arch-run.sh --dry"
OUTPUT=$(bash "$WORKSPACE/linux-arch-run.sh" --dry 2>&1) && {
    pass "linux-arch-run.sh --dry exited 0"
} || {
    fail "linux-arch-run.sh --dry exited non-zero"
}
echo ""

# ── Test 2: linux-arch-dotfiles.sh --dry (no side effects) ───────
info "Test 2: linux-arch-dotfiles.sh --dry"
BEFORE_CONFIG=$(ls -A "$HOME/.config" 2>/dev/null | sort || true)
BEFORE_LOCAL=$(ls -A "$HOME/.local" 2>/dev/null | sort || true)

bash "$WORKSPACE/linux-arch-dotfiles.sh" --dry 2>&1 && {
    pass "linux-arch-dotfiles.sh --dry exited 0"
} || {
    fail "linux-arch-dotfiles.sh --dry exited non-zero"
}

AFTER_CONFIG=$(ls -A "$HOME/.config" 2>/dev/null | sort || true)
AFTER_LOCAL=$(ls -A "$HOME/.local" 2>/dev/null | sort || true)

if [ "$BEFORE_CONFIG" = "$AFTER_CONFIG" ] && [ "$BEFORE_LOCAL" = "$AFTER_LOCAL" ]; then
    pass "Dry run did not modify filesystem"
else
    fail "Dry run modified filesystem (should not happen)"
fi
echo ""

# ── Test 3: linux-arch-dotfiles.sh (real deploy) ─────────────────
info "Test 3: linux-arch-dotfiles.sh (real deploy)"
bash "$WORKSPACE/linux-arch-dotfiles.sh" 2>&1 && {
    pass "linux-arch-dotfiles.sh exited 0"
} || {
    fail "linux-arch-dotfiles.sh exited non-zero"
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

# Arch-specific Hyprland configs
check_dir  "Hyprland config"    "$HOME/.config/hypr"
check_dir  "Waybar config"      "$HOME/.config/waybar"
check_dir  "Rofi config"        "$HOME/.config/rofi"
check_dir  "SwayNC config"      "$HOME/.config/swaync"
check_dir  "Wallust config"     "$HOME/.config/wallust"
check_dir  "Wlogout config"     "$HOME/.config/wlogout"
check_dir  "Cava config"        "$HOME/.config/cava"
check_dir  "Qt5ct config"       "$HOME/.config/qt5ct"
check_dir  "Qt6ct config"       "$HOME/.config/qt6ct"
check_dir  "Swappy config"      "$HOME/.config/swappy"

# Common configs (deploy_file calls for .tmux.conf, .zshrc are commented out in the wrapper)
check_dir  "Claude settings"    "$HOME/.claude"
check_file "Claude settings.json" "$HOME/.claude/settings.json"
check_file "Opencode config"    "$HOME/.config/opencode/opencode.json"

# Local binaries
check_dir  "Local bin"          "$HOME/.local/bin"
check_file "Hyprland launcher"  "$HOME/.local/bin/hyprland-launcher"

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
