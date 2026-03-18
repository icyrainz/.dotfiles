#!/bin/bash
# claude-notify-focus.sh — Record tmux pane on Claude Code notification events
# Writes the tmux target (session:window.pane) and pane ID to a temp file
# so a tmux keybinding can jump to the last notifying Claude session.
#
# Atomic writes via temp file + mv prevent race conditions between concurrent hooks.

[ -z "$TMUX" ] && exit 0
[ -z "$TMUX_PANE" ] && exit 0

NOTIFY_FILE="/tmp/claude-notify-focus"

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
