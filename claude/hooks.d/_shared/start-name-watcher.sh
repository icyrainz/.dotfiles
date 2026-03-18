#!/bin/bash
# start-name-watcher.sh — Launch/ensure the name watcher daemon for this pane
# Runs on SessionStart and UserPromptSubmit. Idempotent: skips if watcher is
# alive and watching the correct transcript.

[ -n "$TMUX" ] || exit 0
[ -n "$TMUX_PANE" ] || exit 0

# Disable automatic-rename early to prevent "2.1.72" version string as window name
window_id=$(tmux display-message -t "$TMUX_PANE" -p '#{window_id}' 2>/dev/null)
[ -n "$window_id" ] && tmux set-option -wt "$window_id" automatic-rename off 2>/dev/null

INPUT=$(cat)
TRANSCRIPT=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('transcript_path',''))" 2>/dev/null)
[ -z "$TRANSCRIPT" ] && exit 0

PIDFILE="/tmp/.claude-name-watcher-${TMUX_PANE}.pid"
TRANSCRIPT_TRACKER="/tmp/.claude-name-watcher-${TMUX_PANE}.transcript"

# Check if watcher is already alive and watching the correct transcript
if [ -f "$PIDFILE" ] && [ -f "$TRANSCRIPT_TRACKER" ]; then
  existing_pid=$(cat "$PIDFILE" 2>/dev/null)
  existing_transcript=$(cat "$TRANSCRIPT_TRACKER" 2>/dev/null)
  if [ -n "$existing_pid" ] && kill -0 "$existing_pid" 2>/dev/null && [ "$existing_transcript" = "$TRANSCRIPT" ]; then
    exit 0  # watcher is alive and on the right transcript
  fi
fi

# Transcript file may not exist yet at SessionStart — wait briefly
for _ in 1 2 3 4 5; do [ -f "$TRANSCRIPT" ] && break; sleep 1; done
[ -f "$TRANSCRIPT" ] || exit 0

# Start watcher in background (detached from hook lifecycle)
nohup bash "$HOME/.config/tmux/claude-name-watcher.sh" "$TRANSCRIPT" "$TMUX_PANE" </dev/null >/dev/null 2>&1 &
disown
