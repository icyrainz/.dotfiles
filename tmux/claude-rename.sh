#!/bin/bash
# claude-rename.sh — After tmux window rename, sync name to Claude Code via /rename
# Called from tmux keybinding: prefix ,
# Reads the (already renamed) window name instead of taking args to avoid quoting issues.

PANE_ID=$(tmux display-message -p '#{pane_id}')

# Check if Claude Code is running on this pane's tty
pane_tty=$(tmux display-message -p '#{pane_tty}' | sed 's|/dev/||')
ps -t "$pane_tty" -o comm= 2>/dev/null | grep -qx claude || exit 0

# Read the new window name (rename-window already ran)
new_name=$(tmux display-message -p '#{window_name}')
[ -z "$new_name" ] && exit 0

# Send /rename to the Claude pane (literal text + Enter separately for TUI compatibility)
tmux send-keys -t "$PANE_ID" -l "/rename $new_name"
tmux send-keys -t "$PANE_ID" Enter
