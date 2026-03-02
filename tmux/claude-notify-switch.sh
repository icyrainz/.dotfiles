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

if [ -z "$PANE_ID" ]; then
  _msg "No Claude notification to jump to"
  exit 0
fi

if ! tmux has-session -t "$PANE_ID" 2>/dev/null; then
  _msg "Pane $TARGET no longer exists"
  rm -f "$NOTIFY_FILE"
  exit 0
fi

# Activate terminal when called from outside tmux
[ -z "$TMUX" ] && open -a WezTerm

# Switch to the session + window + pane
tmux switch-client -t "$TARGET" 2>/dev/null || tmux select-window -t "$TARGET" 2>/dev/null
tmux select-pane -t "$PANE_ID" 2>/dev/null
