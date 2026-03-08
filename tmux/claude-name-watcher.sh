#!/bin/bash
# claude-name-watcher.sh — Background watcher: syncs Claude session name to tmux
# Uses tail -f for event-driven updates. Self-terminates when pane goes away.
# Started by SessionStart hook via start-name-watcher.sh.
#
# Priority: explicit /rename > auto-generated slug

TRANSCRIPT="$1"
PANE_ID="$2"
CACHE="/tmp/.claude-tmux-name-${PANE_ID}"
PIDFILE="/tmp/.claude-name-watcher-${PANE_ID}.pid"

[ -n "$TRANSCRIPT" ] && [ -n "$PANE_ID" ] && [ -f "$TRANSCRIPT" ] || exit 0

# Kill existing watcher for this pane
[ -f "$PIDFILE" ] && kill "$(cat "$PIDFILE")" 2>/dev/null
echo $$ > "$PIDFILE"

cleanup() { rm -f "$PIDFILE"; kill 0 2>/dev/null; }
trap cleanup EXIT

# Self-destruct when pane disappears (check every 15s)
(while sleep 15; do
  tmux display-message -t "$PANE_ID" -p '' 2>/dev/null || kill $$ 2>/dev/null
done) &

prev_name=""

tail -n +1 -f "$TRANSCRIPT" 2>/dev/null | while IFS= read -r line; do
  # Skip assistant messages — they may quote rename/slug patterns from code
  case "$line" in *'"type":"assistant"'*) continue ;; esac

  name=""

  # Prefer explicit /rename (appears in user messages via local-command-stdout)
  case "$line" in
    *'Session renamed to: '*)
      name=$(echo "$line" | sed -n 's/.*Session renamed to: \([^<"\\]*\).*/\1/p')
      ;;
  esac

  # Fall back to slug (appears in system messages)
  if [ -z "$name" ]; then
    case "$line" in
      *'"slug":"'*)
        name=$(echo "$line" | sed -n 's/.*"slug":"\([^"]*\)".*/\1/p')
        ;;
    esac
  fi

  [ -z "$name" ] && continue
  [ "$name" = "$prev_name" ] && continue

  # Also check cache (may have been set by claude-rename.sh)
  [ -f "$CACHE" ] && [ "$(cat "$CACHE" 2>/dev/null)" = "$name" ] && { prev_name="$name"; continue; }

  window_id=$(tmux display-message -t "$PANE_ID" -p '#{window_id}' 2>/dev/null) || break
  tmux rename-window -t "$window_id" "$name"
  echo "$name" > "$CACHE"
  prev_name="$name"
done
