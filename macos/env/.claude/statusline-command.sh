#!/usr/bin/env bash
# Claude Code status line — agnoster-style.
# Reads Claude's session JSON on stdin and prints one line.

set -u

input="$(cat)"

# ---- helpers --------------------------------------------------------------

# Extract a JSON value by dotted path. Reads JSON from stdin; path is $1.
# (Uses `python3 -c` so stdin stays free for the JSON itself — a heredoc on
# python3's stdin would shadow it.)
json() {
  python3 -c '
import json, sys
try:
    data = json.loads(sys.stdin.read())
except Exception:
    sys.exit(0)
cur = data
for p in sys.argv[1].split("."):
    if isinstance(cur, dict) and p in cur:
        cur = cur[p]
    else:
        sys.exit(0)
if cur is None:
    sys.exit(0)
print(cur)
' "$1" 2>/dev/null
}

# Echo the input back so each json call can read it from its own stdin.
j() { printf '%s' "$input" | json "$1"; }

# ---- segments -------------------------------------------------------------

USER_HOST="$(whoami)@$(hostname -s)"

cwd="$(j workspace.current_dir)"
[[ -z "$cwd" ]] && cwd="$(j cwd)"
[[ -z "$cwd" ]] && cwd="$PWD"

# Collapse $HOME to ~ and keep the last 3 path components.
# (Bash tilde-expands `~` in parameter-expansion replacements, so
# `${p/#$HOME/~}` is a no-op — do the prefix swap manually.)
shorten_path() {
  local p="$1"
  if [[ -n "$HOME" && "$p" == "$HOME"* ]]; then
    p="~${p#$HOME}"
  fi
  local IFS=/
  read -r -a parts <<< "$p"
  local n=${#parts[@]}
  if (( n > 3 )); then
    printf '…/%s/%s/%s' "${parts[n-3]}" "${parts[n-2]}" "${parts[n-1]}"
  else
    printf '%s' "$p"
  fi
}
DIR="$(shorten_path "$cwd")"

# Git branch with dirty indicator.
GIT_SEG=""
if branch="$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)" && [[ -n "$branch" ]]; then
  dirty=""
  if ! git -C "$cwd" --no-optional-locks diff --quiet --ignore-submodules 2>/dev/null \
     || ! git -C "$cwd" --no-optional-locks diff --cached --quiet --ignore-submodules 2>/dev/null; then
    dirty=" *"
  fi
  GIT_SEG="${branch}${dirty}"
fi

MODEL="$(j model.display_name)"
[[ -z "$MODEL" ]] && MODEL="$(j model.id)"

# Context-usage progress bar (10 cells).
PCT="$(j context.percentage_used)"
[[ -z "$PCT" ]] && PCT="$(j context_window.used_percentage)"
CTX_SEG=""
if [[ -n "$PCT" ]]; then
  # Round to int.
  pct_int="$(printf '%.0f' "$PCT" 2>/dev/null || echo "")"
  if [[ -n "$pct_int" ]]; then
    filled=$(( pct_int / 10 ))
    (( filled < 0 )) && filled=0
    (( filled > 10 )) && filled=10
    empty=$(( 10 - filled ))
    bar="$(printf '%*s' "$filled" '' | tr ' ' '#')$(printf '%*s' "$empty" '' | tr ' ' '-')"
    CTX_SEG=" [${bar}] ${pct_int}%"
  fi
fi

# ---- colours --------------------------------------------------------------

esc=$'\033'
c_blue="${esc}[38;5;75m"
c_amber="${esc}[38;5;179m"
c_green="${esc}[38;5;114m"
c_violet="${esc}[38;5;141m"
c_grey="${esc}[38;5;245m"
c_reset="${esc}[0m"
sep="${c_grey} | ${c_reset}"

# ---- assemble -------------------------------------------------------------

out="${c_blue}${USER_HOST}${c_reset}${sep}${c_amber}${DIR}${c_reset}"
[[ -n "$GIT_SEG" ]] && out+="${sep}${c_green}${GIT_SEG}${c_reset}"
[[ -n "$MODEL"  ]] && out+="${sep}${c_violet}${MODEL}${CTX_SEG}${c_reset}"

printf '%s' "$out"
