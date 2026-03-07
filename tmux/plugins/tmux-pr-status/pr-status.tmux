#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

nohup "$CURRENT_DIR/scripts/pr-status-daemon.sh" 60 >/dev/null 2>&1 &
disown
