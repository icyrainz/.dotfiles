#!/bin/bash
# start-name-watcher.sh — Launch the name watcher daemon for this pane
# Only runs on SessionStart. The watcher handles continuous sync after that.

[ -n "$TMUX" ] || exit 0
[ -n "$TMUX_PANE" ] || exit 0

INPUT=$(cat)
TRANSCRIPT=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('transcript_path',''))" 2>/dev/null)
[ -z "$TRANSCRIPT" ] && exit 0

# Transcript file may not exist yet at SessionStart — wait briefly
for _ in 1 2 3 4 5; do [ -f "$TRANSCRIPT" ] && break; sleep 1; done
[ -f "$TRANSCRIPT" ] || exit 0

# Start watcher in background (detached from hook lifecycle)
nohup bash "$HOME/.config/tmux/claude-name-watcher.sh" "$TRANSCRIPT" "$TMUX_PANE" </dev/null >/dev/null 2>&1 &
disown
