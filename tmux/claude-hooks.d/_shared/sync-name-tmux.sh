#!/bin/bash
# sync-name-tmux.sh — After Claude stops, sync session name to tmux window
# Reads the transcript to find the latest "Session renamed to:" and applies it.
# grep streams line-by-line so this is fine even on large transcripts.

[ -n "$TMUX" ] || exit 0
[ -n "$TMUX_PANE" ] || exit 0

INPUT=$(cat)
TRANSCRIPT=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('transcript_path',''))" 2>/dev/null)
[ -z "$TRANSCRIPT" ] || [ ! -f "$TRANSCRIPT" ] && exit 0

# Extract latest session name (only from local_command lines, not tool output)
session_name=$(grep '"subtype":"local_command"' "$TRANSCRIPT" 2>/dev/null | grep -o 'Session renamed to: [^<]*' | tail -1 | sed 's/Session renamed to: //')
[ -z "$session_name" ] && exit 0

# Skip if already synced (cache per pane)
CACHE="/tmp/.claude-tmux-name-${TMUX_PANE}"
[ -f "$CACHE" ] && [ "$(cat "$CACHE" 2>/dev/null)" = "$session_name" ] && exit 0

# Find the window containing Claude's pane
window_id=$(tmux display-message -t "$TMUX_PANE" -p '#{window_id}' 2>/dev/null)
[ -z "$window_id" ] && exit 0

tmux rename-window -t "$window_id" "$session_name"
echo "$session_name" > "$CACHE"
