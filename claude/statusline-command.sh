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

# --- Context bar (10 blocks) scaled to 85% ceiling ---
# Autocompact fires at ~85%, so the bar tops out there instead of 100%.
# Gradual color: default → yellow → orange → red as it approaches 85%.
CEIL=77
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
bar=""
if [ -n "$used" ]; then
  u=${used%.*}
  filled=$(( u * 10 / CEIL ))
  [ "$filled" -gt 10 ] && filled=10
  for i in 1 2 3 4 5 6 7 8 9 10; do
    if [ "$i" -le "$filled" ]; then bar="${bar}█"; else bar="${bar}░"; fi
  done
  if [ "$filled" -ge 10 ]; then
    BAR_COLOR=$'\033[0;31m'      # red — last bar
  elif [ "$filled" -ge 8 ]; then
    BAR_COLOR=$'\033[38;5;208m'  # orange
  elif [ "$filled" -ge 6 ]; then
    BAR_COLOR=$'\033[0;33m'      # yellow
  else
    BAR_COLOR=""
  fi
  RST=$'\033[0m'
  ctx_part=" | ${BAR_COLOR}${bar}${RST}"
else
  ctx_part=""
fi

# ANSI colours (dimmed-friendly)
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RESET='\033[0m'

printf "${CYAN}%s${RESET}${YELLOW}%s${RESET} | %s%s\n" \
  "$short_cwd" "$branch" "$model" "$ctx_part"
