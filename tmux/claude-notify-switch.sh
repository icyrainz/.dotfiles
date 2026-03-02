#!/bin/bash
# claude-notify-switch.sh — Switch to the tmux pane that last sent a Claude notification
# Bound to a tmux keybinding (e.g., prefix + n)

NOTIFY_FILE="/tmp/claude-notify-focus"

if [ ! -f "$NOTIFY_FILE" ]; then
  tmux display-message "No Claude notification to jump to"
  exit 0
fi

# Source the saved target
. "$NOTIFY_FILE"

if [ -z "$PANE_ID" ]; then
  tmux display-message "No Claude notification to jump to"
  exit 0
fi

# Check the pane still exists
if ! tmux has-session -t "$PANE_ID" 2>/dev/null; then
  tmux display-message "Pane $TARGET no longer exists"
  rm -f "$NOTIFY_FILE"
  exit 0
fi

# Switch to the session + window + pane
tmux switch-client -t "$TARGET" 2>/dev/null || tmux select-window -t "$TARGET" 2>/dev/null
tmux select-pane -t "$PANE_ID" 2>/dev/null
