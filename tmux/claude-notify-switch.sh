#!/bin/bash
# claude-notify-switch.sh — Jump to the tmux pane that last sent a Claude notification
# Works from both tmux keybinding (prefix + n) and global hotkey (BetterTouchTool).

export PATH="/opt/homebrew/bin:$PATH"
NOTIFY_FILE="/tmp/claude-notify-focus"

_msg() {
  if [ -n "$TMUX" ]; then
    tmux display-message "$1"
  else
    osascript -e "display notification \"$1\" with title \"peon-ping\""
  fi
}

if [ ! -f "$NOTIFY_FILE" ] || [ -z "$(cat "$NOTIFY_FILE")" ]; then
  _msg "No Claude notification to jump to"
  exit 0
fi

. "$NOTIFY_FILE"

if [ -z "$PANE_ID" ] || [ -z "$TARGET" ]; then
  _msg "No Claude notification to jump to"
  exit 0
fi

# Extract session name from TARGET (format: session:window.pane)
SESSION_NAME="${TARGET%%:*}"

# Validate the session still exists
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  _msg "Session $SESSION_NAME no longer exists"
  rm -f "$NOTIFY_FILE"
  exit 0
fi

# Validate the pane still exists
if ! tmux display-message -t "$PANE_ID" -p '#{pane_id}' >/dev/null 2>&1; then
  _msg "Pane $PANE_ID no longer exists"
  rm -f "$NOTIFY_FILE"
  exit 0
fi

# Activate terminal when called from outside tmux
[ -z "$TMUX" ] && open -a WezTerm

# Find the first attached client to switch (needed when called outside tmux)
CLIENT=$(tmux list-clients -F '#{client_tty}' 2>/dev/null | head -1)

if [ -n "$CLIENT" ]; then
  tmux switch-client -c "$CLIENT" -t "$TARGET" 2>/dev/null
else
  tmux select-window -t "$TARGET" 2>/dev/null
fi
tmux select-pane -t "$PANE_ID" 2>/dev/null

# Clear after jumping
: > "$NOTIFY_FILE"
