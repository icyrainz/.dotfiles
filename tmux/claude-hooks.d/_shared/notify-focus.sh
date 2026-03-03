#!/bin/bash
# claude-notify-focus.sh — Record tmux pane on Claude Code notification events
# Added as a Claude Code hook alongside peon-ping for: Stop, Notification, PermissionRequest
#
# Writes the tmux target (session:window.pane) and pane ID to a temp file
# so a tmux keybinding can jump to the last notifying Claude session.
#
# Design: only BACKGROUND panes write. The focused pane never records itself
# because you're already looking at it — cmd+\ is for finding background sessions.
# Atomic writes via temp file + mv prevent race conditions between concurrent hooks.

[ -z "$TMUX" ] && exit 0
[ -z "$TMUX_PANE" ] && exit 0

NOTIFY_FILE="/tmp/claude-notify-focus"

# Focused pane never writes — you're already looking at it
# Must check session_attached too: a pane can be "active" in a detached session
is_visible=$(tmux display-message -t "$TMUX_PANE" -p '#{session_attached}#{window_active}#{pane_active}' 2>/dev/null)
[ "$is_visible" = "111" ] && exit 0

# Determine event type from stdin JSON
EVENT=$(python3 -c "import json,sys; print(json.load(sys.stdin).get('hook_event_name',''))" 2>/dev/null)

# Stop and PermissionRequest = "needs attention" (high priority)
# Notification = informational only (low priority)
is_high_priority=false
case "$EVENT" in
  Stop|PermissionRequest) is_high_priority=true ;;
esac

# Low-priority events never overwrite existing high-priority ones
if [ "$is_high_priority" = false ] && [ -f "$NOTIFY_FILE" ]; then
  . "$NOTIFY_FILE"
  [ "$PRIORITY" = "high" ] && exit 0
fi

# Resolve pane ID → session:window.pane
target=$(tmux display-message -t "$TMUX_PANE" -p '#{session_name}:#{window_index}.#{pane_index}' 2>/dev/null) || exit 0
window_name=$(tmux display-message -t "$TMUX_PANE" -p '#{window_name}' 2>/dev/null)
pane_id="$TMUX_PANE"
priority=$($is_high_priority && echo high || echo low)

# Atomic write: temp file + mv prevents races between concurrent hooks
TMP=$(mktemp /tmp/claude-notify-focus.XXXXXX)
cat > "$TMP" <<EOF
TARGET="$target"
PANE_ID="$pane_id"
WINDOW_NAME="$window_name"
PRIORITY="$priority"
TIMESTAMP="$(date +%s)"
EOF
mv -f "$TMP" "$NOTIFY_FILE"
