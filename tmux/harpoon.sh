#!/usr/bin/env bash
# tmux session harpoon — pin sessions to slots and jump to them
set -euo pipefail

HARPOON_FILE="${HOME}/.config/tmux/harpoon-sessions"
MAX_SLOTS=4

ensure_file() {
  mkdir -p "$(dirname "$HARPOON_FILE")"
  touch "$HARPOON_FILE"
  local lines
  lines=$(wc -l < "$HARPOON_FILE")
  while [ "$lines" -lt "$MAX_SLOTS" ]; do
    echo "" >> "$HARPOON_FILE"
    lines=$((lines + 1))
  done
}

mark() {
  local slot="$1"
  local session
  session=$(tmux display-message -p '#S')
  ensure_file
  # awk replace is portable across macOS and Linux (no sed -i differences)
  local tmp="${HARPOON_FILE}.tmp"
  awk -v s="$slot" -v val="$session" 'NR==s{print val;next}{print}' "$HARPOON_FILE" > "$tmp"
  mv "$tmp" "$HARPOON_FILE"
  tmux display-message "harpoon [${slot}] → ${session}"
}

goto_slot() {
  local slot="$1"
  ensure_file
  local session
  session=$(sed -n "${slot}p" "$HARPOON_FILE")
  if [ -n "$session" ] && tmux has-session -t "=$session" 2>/dev/null; then
    tmux switch-client -t "=$session"
  else
    tmux display-message "harpoon [${slot}] empty or session gone"
  fi
}

case "${1:-}" in
  mark) mark "${2:-1}" ;;
  goto) goto_slot "${2:-1}" ;;
  *)    echo "Usage: harpoon.sh {mark|goto} <slot>" ;;
esac
