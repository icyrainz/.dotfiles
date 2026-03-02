#!/bin/bash
# claude-notify-focus.sh — Record tmux pane on Claude Code notification events
# Added as a Claude Code hook alongside peon-ping for: Stop, Notification, PermissionRequest
#
# Writes the tmux target (session:window.pane) and pane ID to a temp file
# so a tmux keybinding can jump to the last notifying Claude session.

[ -z "$TMUX" ] && exit 0
[ -z "$TMUX_PANE" ] && exit 0

NOTIFY_FILE="/tmp/claude-notify-focus"

# Determine event type from stdin JSON
EVENT=$(python3 -c "import json,sys; print(json.load(sys.stdin).get('hook_event_name',''))" 2>/dev/null)

# Stop and PermissionRequest = "needs attention" (high priority)
# Notification = informational only (low priority)
is_high_priority=false
case "$EVENT" in
  Stop|PermissionRequest) is_high_priority=true ;;
esac

# Focused pane: only write as fallback when file is empty (single-session case)
# Never let focused pane overwrite a background notification
is_focused=$(tmux display-message -t "$TMUX_PANE" -p '#{window_active}#{pane_active}' 2>/dev/null)
[ "$is_focused" = "11" ] && [ -s "$NOTIFY_FILE" ] && exit 0

# Low-priority events (Notification) never overwrite existing high-priority ones
if [ "$is_high_priority" = false ] && [ -s "$NOTIFY_FILE" ]; then
  . "$NOTIFY_FILE"
  [ "$PRIORITY" = "high" ] && exit 0
fi

# Resolve pane ID → session:window.pane
target=$(tmux display-message -t "$TMUX_PANE" -p '#{session_name}:#{window_index}.#{pane_index}' 2>/dev/null) || exit 0
window_name=$(tmux display-message -t "$TMUX_PANE" -p '#{window_name}' 2>/dev/null)
pane_id="$TMUX_PANE"
priority=$($is_high_priority && echo high || echo low)

# Write as simple key=value for easy sourcing
cat > "$NOTIFY_FILE" <<EOF
TARGET="$target"
PANE_ID="$pane_id"
WINDOW_NAME="$window_name"
PRIORITY="$priority"
TIMESTAMP="$(date +%s)"
EOF
