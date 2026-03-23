#!/usr/bin/env bash
# tmux-claude-stats entry point — started by tmux via run-shell

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

get_tmux_option() {
    local option_value
    option_value=$(tmux show-option -gqv "$1")
    if [ -z "$option_value" ]; then
        echo "$2"
    else
        echo "$option_value"
    fi
}

# Read config
format=$(get_tmux_option "@claude-stats-format" '%5h{60,90}✦')
interval=$(get_tmux_option "@claude-stats-interval" "300")
warn=$(get_tmux_option "@claude-stats-warn" "60")
crit=$(get_tmux_option "@claude-stats-crit" "90")

# Start daemon if not already running (pidfile dedup)
pidfile="/tmp/claude-stats.pid"
start_daemon=true

if [ -f "$pidfile" ]; then
    pid=$(cat "$pidfile" 2>/dev/null)
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
        start_daemon=false
    fi
fi

if [ "$start_daemon" = true ]; then
    "$CURRENT_DIR/scripts/daemon.sh" "$interval" &
    disown 2>/dev/null
fi

# Register #{claude_stats} interpolation via string substitution
# Escape % as %% so tmux's strftime pass doesn't eat our template variables
escaped_format="${format//%/%%}"
placeholder="\#{claude_stats}"
replacement="#($CURRENT_DIR/scripts/status.sh '${escaped_format}' ${warn} ${crit})"

for option in "status-left" "status-right"; do
    option_value=$(get_tmux_option "$option" "")
    if [[ "$option_value" == *'#{claude_stats}'* ]]; then
        new_value="${option_value/$placeholder/$replacement}"
        tmux set-option -gq "$option" "$new_value"
    fi
done
