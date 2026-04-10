#!/bin/bash
# Set window indicator to "running"
[ -n "$TMUX" ] && [ -n "$TMUX_PANE" ] || exit 0
window_id=$(tmux display-message -t "$TMUX_PANE" -p '#{window_id}' 2>/dev/null)
[ -n "$window_id" ] && tmux set-option -wt "$window_id" @claude-state " ▶"
