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
WRAPPER="./linux-arch-dotfiles.sh"

echo "========================================="
echo "  Tag filtering — Docker Test Suite"
echo "========================================="
echo ""
info "Note: linux-arch-run.sh looks at \$DEV_ENV/runs/ which is"
info "linux/runs/ — that directory doesn't exist in this repo,"
info "so run_scripts tests are skipped. Only dotfiles tested here."
echo ""

# strip_ansi — remove ANSI escape codes from piped input
strip_ansi() { sed 's/\x1b\[[0-9;]*m//g'; }

# ── Test 1: No tags = deploy everything ───────────────────────────
info "Test 1: --dry (no tags) deploys all dirs"
OUTPUT=$(bash "$WRAPPER" --dry 2>&1 | strip_ansi)
for dir in hypr waybar rofi swaync wallust wlogout cava kitty swappy qt5ct qt6ct wal; do
    if echo "$OUTPUT" | grep -qF "./$dir "; then
        pass "$dir included (expected)"
    else
        fail "$dir should be included but was filtered or missing"
    fi
done
echo ""

# ── Test 2: Single tag filters correctly ──────────────────────────
info "Test 2: --dry --tags hyprland only includes hyprland-tagged dirs"
OUTPUT=$(bash "$WRAPPER" --dry --tags hyprland 2>&1 | strip_ansi)
for dir in hypr waybar wlogout wallust; do
    if echo "$OUTPUT" | grep -qF "./$dir "; then
        pass "$dir included with tag hyprland"
    else
        fail "$dir should be included (tagged hyprland)"
    fi
done
for dir in rofi swaync cava kitty swappy qt5ct qt6ct wal btop fastfetch nvim personal; do
    if echo "$OUTPUT" | grep -qF "./$dir "; then
        fail "$dir should NOT be included (not tagged hyprland)"
    else
        pass "$dir correctly excluded (not tagged hyprland)"
    fi
done
echo ""

# ── Test 3: Multi-tag OR works ────────────────────────────────────
info "Test 3: --dry --tags hyprland,screenshot includes both"
OUTPUT=$(bash "$WRAPPER" --dry --tags hyprland,screenshot 2>&1 | strip_ansi)
for dir in hypr waybar swappy; do
    if echo "$OUTPUT" | grep -qF "./$dir "; then
        pass "$dir included with tags hyprland,screenshot"
    else
        fail "$dir should be included (tagged hyprland or screenshot)"
    fi
done
if echo "$OUTPUT" | grep -qF "./rofi "; then
    fail "rofi should NOT be included (tagged ui, not hyprland or screenshot)"
else
    pass "rofi correctly excluded (tagged ui)"
fi
echo ""

# ── Test 4: No-match tag excludes everything ──────────────────────
info "Test 4: --dry --tags nonexistent excludes all dirs"
OUTPUT=$(bash "$WRAPPER" --dry --tags nonexistent 2>&1 | strip_ansi)
if echo "$OUTPUT" | grep -q "syncing:"; then
    fail "No dirs should be synced with nonexistent tag"
else
    pass "All dirs excluded with nonexistent tag"
fi
echo ""

# ── Test 5: deploy_file tag filtering ─────────────────────────────
info "Test 5: --dry --tags shell only includes shell-tagged files"
OUTPUT=$(bash "$WRAPPER" --dry --tags shell 2>&1 | strip_ansi)
if echo "$OUTPUT" | grep -q "copying:.*\.zshrc"; then
    pass ".zshrc included (tagged shell)"
else
    fail ".zshrc should be included (tagged shell)"
fi
if echo "$OUTPUT" | grep -q "copying:.*\.tmux.conf"; then
    fail ".tmux.conf should NOT be included (tagged tmux, not shell)"
else
    pass ".tmux.conf correctly excluded (tagged tmux)"
fi
echo ""

# ── Test 6: deploy_file with no tag when filtering active ────────
info "Test 6: --dry --tags editor includes editor-tagged files"
OUTPUT=$(bash "$WRAPPER" --dry --tags editor 2>&1 | strip_ansi)
if echo "$OUTPUT" | grep -q "copying:.*settings.json"; then
    pass "claude settings.json included (tagged editor,ai)"
else
    fail "claude settings.json should be included (tagged editor,ai)"
fi
echo ""

# ── Summary ──────────────────────────────────────────────────────
echo "========================================="
if [ "$FAILURES" -eq 0 ]; then
    echo -e "${GREEN}  All tag tests passed!${NC}"
    exit 0
else
    echo -e "${RED}  $FAILURES test(s) failed${NC}"
    exit 1
fi
