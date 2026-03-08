#!/bin/bash
# sync-name-tmux.sh — Sync Claude session name to tmux window
# Priority: explicit /rename > auto-generated slug
# grep streams line-by-line so this is fine even on large transcripts.

[ -n "$TMUX" ] || exit 0
[ -n "$TMUX_PANE" ] || exit 0

INPUT=$(cat)
TRANSCRIPT=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('transcript_path',''))" 2>/dev/null)
[ -z "$TRANSCRIPT" ] || [ ! -f "$TRANSCRIPT" ] && exit 0

# 1. Prefer explicit /rename (user-chosen name)
session_name=$(grep '"subtype":"local_command"' "$TRANSCRIPT" 2>/dev/null | grep -o 'Session renamed to: [^<]*' | tail -1 | sed 's/Session renamed to: //')

# 2. Fall back to auto-generated slug
if [ -z "$session_name" ]; then
  session_name=$(grep -o '"slug":"[^"]*"' "$TRANSCRIPT" 2>/dev/null | tail -1 | cut -d'"' -f4)
fi

[ -z "$session_name" ] && exit 0

# Skip if already synced (cache per pane)
CACHE="/tmp/.claude-tmux-name-${TMUX_PANE}"
[ -f "$CACHE" ] && [ "$(cat "$CACHE" 2>/dev/null)" = "$session_name" ] && exit 0

# Find the window containing Claude's pane
window_id=$(tmux display-message -t "$TMUX_PANE" -p '#{window_id}' 2>/dev/null)
[ -z "$window_id" ] && exit 0

tmux rename-window -t "$window_id" "$session_name"
echo "$session_name" > "$CACHE"
