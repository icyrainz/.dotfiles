#!/bin/bash
# claude-hook.sh — Generic Claude Code hook shim
# Usage: Registered as a Claude Code hook. Reads event JSON from stdin.
#
# Runs all scripts in ~/.config/tmux/claude-hooks.d/<EventType>/*.sh
# Passes the original stdin JSON to each hook script.
# Add/remove/edit hooks without restarting Claude Code.
#
# Structure:
#   claude-hooks.d/
#     _shared/peon-ping.sh
#     _shared/notify-focus.sh
#     Stop/peon-ping.sh           -> ../_shared/peon-ping.sh
#     Stop/notify-focus.sh        -> ../_shared/notify-focus.sh

# Read stdin once
INPUT=$(cat)
EVENT=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('hook_event_name',''))" 2>/dev/null)
[ -z "$EVENT" ] && exit 0

HOOKS_DIR="$HOME/.config/tmux/claude-hooks.d/$EVENT"
[ -d "$HOOKS_DIR" ] || exit 0

for hook in "$HOOKS_DIR"/*.sh; do
  [ -f "$hook" ] && echo "$INPUT" | bash "$hook" &
done
wait
