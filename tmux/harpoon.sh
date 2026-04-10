#!/usr/bin/env bash
# tmux harpoon — pin windows to slots, jump with Alt+1-4
# Format per line: session:window_id (native tmux target syntax)
# goto tries exact target first, falls back to session only
set -euo pipefail

FILE="${HOME}/.config/tmux/harpoon-sessions"
TASKS="${HOME}/.local/share/laundry/tasks.json"

_write() {
  local slot="$1" val="$2"
  mkdir -p "$(dirname "$FILE")" && touch "$FILE"
  while [ "$(wc -l < "$FILE")" -lt 4 ]; do echo "" >> "$FILE"; done
  awk -v s="$slot" -v v="$val" 'NR==s{print v;next}{print}' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
}

case "${1:-}" in
  goto)
    slot="${2:-1}"
    target=$(sed -n "${slot}p" "$FILE" 2>/dev/null)
    session="${target%%:*}"
    if [ -z "$target" ]; then
      tmux display-message "harpoon [$slot] empty"
    elif tmux switch-client -t "$target" 2>/dev/null; then
      : # switched to session:window
    elif [ -n "$session" ] && tmux has-session -t "=$session" 2>/dev/null; then
      tmux switch-client -t "=$session"
    else
      tmux display-message "harpoon [$slot] gone"
    fi
    ;;
  mark)
    slot="${2:-1}"
    val="$(tmux display-message -p '#S:#{window_id}')"
    _write "$slot" "$val"
    tmux display-message "harpoon [$slot] → $val"
    ;;
  pin)
    slot="${2:-1}"
    task_id="${3:?task_id required}"
    # tasks.json stores full tmux target (session:@N) — just extract it
    target=$(grep -A15 "\"id\": \"$task_id\"" "$TASKS" | grep '"tmux_window_id"' | head -1 | sed 's/.*": *"\([^"]*\)".*/\1/')
    [ -z "$target" ] && exit 0
    _write "$slot" "$target"
    ;;
  *) echo "Usage: harpoon.sh {goto|mark|pin} <slot> [task_id]" ;;
esac
