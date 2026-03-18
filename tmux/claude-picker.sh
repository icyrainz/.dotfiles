#!/usr/bin/env bash
# claude-picker.sh — fzf picker for all tmux panes running Claude Code
# Scans all sessions/windows/panes, finds ones running claude, lets you switch.

entries=""
while read -r target wname pane_id cmd tty; do
  if [[ "$cmd" == "claude" ]] || ps -t "$tty" -o comm= 2>/dev/null | grep -q '^claude$'; then
    entries+="$(printf '%-25s %-20s %s' "$target" "$wname" "$pane_id")"$'\n'
  fi
done < <(tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} #{window_name} #{pane_id} #{pane_current_command} #{pane_tty}')

if [ -z "$entries" ]; then
  tmux display-message "No Claude sessions found"
  exit 0
fi

selected=$(printf '%s' "$entries" | fzf-tmux -p 55%,40% \
  --no-sort \
  --border-label ' claude sessions ' \
  --prompt '> ' \
  --header 'target                    window name' \
  --with-nth=1,2)

[ -z "$selected" ] && exit 0

target=$(echo "$selected" | awk '{print $1}')
pane_id=$(echo "$selected" | awk '{print $NF}')

tmux switch-client -t "$target" 2>/dev/null
tmux select-pane -t "$pane_id" 2>/dev/null
