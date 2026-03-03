#!/bin/bash
# claude-notify-focus.sh — Record tmux pane on Claude Code notification events
# Added as a Claude Code hook alongside peon-ping for: Stop, Notification, PermissionRequest
#
# Writes the tmux target (session:window.pane) and pane ID to a temp file
# so a tmux keybinding can jump to the last notifying Claude session.
#
# Always writes — can't reliably detect if user is in another macOS app.
# Atomic writes via temp file + mv prevent race conditions between concurrent hooks.

[ -z "$TMUX" ] && exit 0
[ -z "$TMUX_PANE" ] && exit 0

NOTIFY_FILE="/tmp/claude-notify-focus"

# Only record events that need attention (Stop = task done, PermissionRequest = waiting)
EVENT=$(python3 -c "import json,sys; print(json.load(sys.stdin).get('hook_event_name',''))" 2>/dev/null)
case "$EVENT" in
  Stop|PermissionRequest) ;;
  *) exit 0 ;;
esac

# Resolve pane ID → session:window.pane
target=$(tmux display-message -t "$TMUX_PANE" -p '#{session_name}:#{window_index}.#{pane_index}' 2>/dev/null) || exit 0
window_name=$(tmux display-message -t "$TMUX_PANE" -p '#{window_name}' 2>/dev/null)

# Atomic write: temp file + mv prevents races between concurrent hooks
TMP=$(mktemp /tmp/claude-notify-focus.XXXXXX)
cat > "$TMP" <<EOF
TARGET="$target"
PANE_ID="$TMUX_PANE"
WINDOW_NAME="$window_name"
TIMESTAMP="$(date +%s)"
EOF
mv -f "$TMP" "$NOTIFY_FILE"
