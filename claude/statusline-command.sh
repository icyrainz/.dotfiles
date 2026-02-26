#!/usr/bin/env bash
# Claude Code statusLine — mirrors zsh prompt style:
#   cyan cwd | yellow git branch | model | context bar

input=$(cat)

# --- Directory (git root basename, fallback to tilde-shortened cwd) ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
home="$HOME"
git_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
if [ -n "$git_root" ]; then
  short_cwd=$(basename "$git_root")
else
  short_cwd="${cwd/#$home/\~}"
fi

# --- Git branch ---
branch=""
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  if [ -n "$branch" ] && [ ${#branch} -gt 10 ]; then
    branch="…${branch: -10}"
  fi
  [ -n "$branch" ] && branch=" ($branch)"
fi

# --- Model ---
model=$(echo "$input" | jq -r '.model.display_name')

# --- Context bar (10 blocks) ---
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
bar=""
if [ -n "$used" ]; then
  u=${used%.*}
  for t in 10 20 30 40 50 60 70 80 90 100; do
    if [ "$u" -ge "$t" ]; then bar="${bar}█"; else bar="${bar}░"; fi
  done
  ctx_part=" | $bar"
else
  ctx_part=""
fi

# ANSI colours (dimmed-friendly)
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RESET='\033[0m'

printf "${CYAN}%s${RESET}${YELLOW}%s${RESET} | %s%s\n" \
  "$short_cwd" "$branch" "$model" "$ctx_part"
