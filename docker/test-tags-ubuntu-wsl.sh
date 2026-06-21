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
WRAPPER="./linux-wsl-ubuntu-dotfiles.sh"

echo "========================================="
echo "  Tag filtering — WSL-Ubuntu Test Suite"
echo "========================================="
echo ""

# strip_ansi — remove ANSI escape codes from piped input
strip_ansi() { sed 's/\x1b\[[0-9;]*m//g'; }

# ── Test 1: No tags = deploy everything ───────────────────────────
info "Test 1: --dry (no tags) deploys all expected items"
OUTPUT=$(bash "$WRAPPER" --dry 2>&1 | strip_ansi)

# Should see config dirs from common/
for dir in nvim btop fastfetch personal; do
    if echo "$OUTPUT" | grep -qF "./$dir "; then
        pass "$dir included (expected)"
    else
        fail "$dir should be included but was filtered or missing"
    fi
done

# Should see config dirs from arch/ (shared linux configs)
for dir in kitty yazi; do
    if echo "$OUTPUT" | grep -qF "./$dir "; then
        pass "$dir included (expected)"
    else
        fail "$dir should be included but was filtered or missing"
    fi
done

# Should see deploy_file calls
for file in "settings.json" "opencode.json" ".zshrc" ".tmux.conf"; do
    if echo "$OUTPUT" | grep -q "copying:.*$file"; then
        pass "$file deployed (expected)"
    else
        fail "$file should be deployed but was filtered or missing"
    fi
done
echo ""

# ── Test 2: Single tag filters correctly ──────────────────────────
info "Test 2: --dry --tags shell only includes shell-tagged files"
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

# ── Test 3: --tags editor includes editor-tagged files ────────────
info "Test 3: --dry --tags editor includes editor-tagged files"
OUTPUT=$(bash "$WRAPPER" --dry --tags editor 2>&1 | strip_ansi)
if echo "$OUTPUT" | grep -q "copying:.*settings.json"; then
    pass "claude settings.json included (tagged editor,ai)"
else
    fail "claude settings.json should be included (tagged editor,ai)"
fi
if echo "$OUTPUT" | grep -q "copying:.*opencode.json"; then
    pass "opencode.json included (tagged editor,ai)"
else
    fail "opencode.json should be included (tagged editor,ai)"
fi
echo ""

# ── Test 4: No-match tag excludes everything ──────────────────────
info "Test 4: --dry --tags nonexistent excludes all items"
OUTPUT=$(bash "$WRAPPER" --dry --tags nonexistent 2>&1 | strip_ansi)
if echo "$OUTPUT" | grep -q "syncing:"; then
    fail "No dirs should be synced with nonexistent tag"
else
    pass "All dirs excluded with nonexistent tag"
fi
if echo "$OUTPUT" | grep -q "copying:"; then
    fail "No files should be deployed with nonexistent tag"
else
    pass "All files excluded with nonexistent tag"
fi
echo ""

# ── Test 5: --exclude filters out tagged items ─────────────────────
info "Test 5: --dry --exclude shell excludes shell-tagged files"
OUTPUT=$(bash "$WRAPPER" --dry --exclude shell 2>&1 | strip_ansi)
if echo "$OUTPUT" | grep -q "copying:.*\.zshrc"; then
    fail ".zshrc should NOT be included (tagged shell, --exclude shell)"
else
    pass ".zshrc correctly excluded (--exclude shell)"
fi
if echo "$OUTPUT" | grep -q "copying:.*settings.json"; then
    pass "claude settings.json still included (tagged editor,ai, not excluded)"
else
    fail "claude settings.json should still be included (not excluded)"
fi
echo ""

# ── Test 6: --tags + --exclude combined ───────────────────────────
info "Test 6: --dry --tags editor --exclude ai"
OUTPUT=$(bash "$WRAPPER" --dry --tags editor --exclude ai 2>&1 | strip_ansi)
if echo "$OUTPUT" | grep -q "copying:.*settings.json"; then
    fail "settings.json should NOT be included (tagged ai, excluded)"
else
    pass "settings.json correctly excluded (tagged ai, --exclude ai)"
fi
if echo "$OUTPUT" | grep -q "copying:.*opencode.json"; then
    fail "opencode.json should NOT be included (tagged ai, excluded)"
else
    pass "opencode.json correctly excluded (tagged ai, --exclude ai)"
fi
echo ""

# ── Test 7: --exclude multi-tag on files ──────────────────────────
info "Test 7: --dry --exclude shell,tmux excludes shell and tmux files"
OUTPUT=$(bash "$WRAPPER" --dry --exclude shell,tmux 2>&1 | strip_ansi)
if echo "$OUTPUT" | grep -q "copying:.*\.zshrc"; then
    fail ".zshrc should NOT be included (tagged shell, --exclude shell)"
else
    pass ".zshrc correctly excluded (--exclude shell)"
fi
if echo "$OUTPUT" | grep -q "copying:.*\.tmux.conf"; then
    fail ".tmux.conf should NOT be included (tagged tmux, --exclude tmux)"
else
    pass ".tmux.conf correctly excluded (--exclude tmux)"
fi
if echo "$OUTPUT" | grep -q "copying:.*settings.json"; then
    pass "claude settings.json still included (tagged editor,ai, not excluded)"
else
    fail "claude settings.json should still be included (not excluded)"
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
