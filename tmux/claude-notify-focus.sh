#!/bin/bash
# claude-notify-focus.sh — Record tmux pane on Claude Code notification events
# Added as a Claude Code hook alongside peon-ping for: Stop, Notification, PermissionRequest
#
# Writes the tmux target (session:window.pane) and pane ID to a temp file
# so a tmux keybinding can jump to the last notifying Claude session.

[ -z "$TMUX" ] && exit 0
[ -z "$TMUX_PANE" ] && exit 0

NOTIFY_FILE="/tmp/claude-notify-focus"

# Resolve pane ID → session:window.pane
target=$(tmux display-message -t "$TMUX_PANE" -p '#{session_name}:#{window_index}.#{pane_index}' 2>/dev/null) || exit 0
window_name=$(tmux display-message -t "$TMUX_PANE" -p '#{window_name}' 2>/dev/null)
pane_id="$TMUX_PANE"

# Write as simple key=value for easy sourcing
cat > "$NOTIFY_FILE" <<EOF
TARGET=$target
PANE_ID=$pane_id
WINDOW_NAME=$window_name
TIMESTAMP=$(date +%s)
EOF
