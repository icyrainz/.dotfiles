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
TRANSCRIPT_TRACKER="/tmp/.claude-name-watcher-${PANE_ID}.transcript"

[ -n "$TRANSCRIPT" ] && [ -n "$PANE_ID" ] && [ -f "$TRANSCRIPT" ] || exit 0

# Skip subagent sessions — they never get slugs and would linger as idle watchers.
# Check isSidechain field (parentToolUseID exists in ALL sessions, not just subagents).
head -1 "$TRANSCRIPT" | python3 -c "import json,sys; d=json.loads(sys.stdin.readline()); exit(0 if d.get('isSidechain') else 1)" 2>/dev/null && exit 0

# Kill existing watcher for this pane
[ -f "$PIDFILE" ] && kill "$(cat "$PIDFILE")" 2>/dev/null
echo $$ > "$PIDFILE"
echo "$TRANSCRIPT" > "$TRANSCRIPT_TRACKER"

# Immediately disable automatic-rename to prevent tmux from overriding the name
# with the Claude process title (version string like "2.1.72").
window_id=$(tmux display-message -t "$PANE_ID" -p '#{window_id}' 2>/dev/null)
if [ -n "$window_id" ]; then
  tmux set-option -wt "$window_id" automatic-rename off 2>/dev/null
  # Set fallback name from project cwd until slug arrives
  fallback=$(head -1 "$TRANSCRIPT" | python3 -c "import json,sys,os; print(os.path.basename(json.loads(sys.stdin.readline()).get('cwd','')))" 2>/dev/null)
  [ -n "$fallback" ] && tmux rename-window -t "$window_id" "$fallback"
fi

# Only remove pidfile if it still belongs to us (avoids race with new watcher)
cleanup() {
  if [ -f "$PIDFILE" ] && [ "$(cat "$PIDFILE" 2>/dev/null)" = "$$" ]; then
    rm -f "$PIDFILE" "$TRANSCRIPT_TRACKER"
  fi
  kill 0 2>/dev/null
}
trap cleanup EXIT

# Self-destruct when pane disappears (check every 15s)
# Note: display-message -p always exits 0, so use list-panes instead
(while sleep 15; do
  tmux list-panes -t "$PANE_ID" >/dev/null 2>&1 || kill $$ 2>/dev/null
done) &

prev_name=""
has_explicit_rename=false
slug_set=false

tail -n +1 -f "$TRANSCRIPT" 2>/dev/null | while IFS= read -r line; do
  # Skip assistant messages — they may quote rename/slug patterns from code
  case "$line" in *'"type":"assistant"'*) continue ;; esac

  name=""

  # Prefer explicit /rename (appears in local_command subtype lines only)
  # Guard against false positives from tool results containing source code
  case "$line" in
    *'"subtype":"local_command"'*'Session renamed to: '*)
      name=$(echo "$line" | sed -n 's/.*Session renamed to: \([^<"\\]*\).*/\1/p')
      if [ -n "$name" ]; then
        has_explicit_rename=true
      fi
      ;;
  esac

  # Fall back to slug only if no explicit /rename has been seen yet
  # and we haven't set the slug already (it repeats on every line)
  if [ -z "$name" ] && [ "$has_explicit_rename" = false ] && [ "$slug_set" = false ]; then
    case "$line" in
      *'"slug":"'*)
        name=$(echo "$line" | sed -n 's/.*"slug":"\([^"]*\)".*/\1/p')
        [ -n "$name" ] && slug_set=true
        ;;
    esac
  fi

  [ -z "$name" ] && continue
  [ "$name" = "$prev_name" ] && continue

  # Also check cache (may have been set by claude-rename.sh)
  [ -f "$CACHE" ] && [ "$(cat "$CACHE" 2>/dev/null)" = "$name" ] && { prev_name="$name"; continue; }

  tmux list-panes -t "$PANE_ID" >/dev/null 2>&1 || break
  window_id=$(tmux display-message -t "$PANE_ID" -p '#{window_id}' 2>/dev/null)
  tmux rename-window -t "$window_id" "$name"
  echo "$name" > "$CACHE"
  prev_name="$name"
done
