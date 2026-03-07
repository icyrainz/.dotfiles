#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INTERVAL="${1:-60}"
PIDFILE="/tmp/tmux-pr-status-daemon.pid"

if [ -f "$PIDFILE" ]; then
    old_pid=$(cat "$PIDFILE" 2>/dev/null || true)
    if [ -n "$old_pid" ] && kill -0 "$old_pid" 2>/dev/null; then
        exit 0
    fi
fi
echo $$ > "$PIDFILE"

cleanup() {
    rm -f "$PIDFILE"
    exit 0
}
trap cleanup EXIT INT TERM

while true; do
    "$SCRIPT_DIR/check-pr-status.sh" --all
    sleep "$INTERVAL"
done
