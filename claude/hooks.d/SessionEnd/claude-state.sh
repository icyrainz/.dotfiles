#!/bin/bash
# Clear window indicator when session ends
[ -n "$TMUX" ] && [ -n "$TMUX_PANE" ] || exit 0
window_id=$(tmux display-message -t "$TMUX_PANE" -p '#{window_id}' 2>/dev/null)
[ -n "$window_id" ] && tmux set-option -wut "$window_id" @claude-state
