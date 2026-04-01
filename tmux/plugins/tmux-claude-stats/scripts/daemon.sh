#!/usr/bin/env bash
# Claude Code rate limit daemon — fetches OAuth usage API and writes cache

INTERVAL="${1:-300}"
CACHE_FILE="/tmp/claude-stats.json"
CACHE_TMP="/tmp/claude-stats.json.tmp"
PIDFILE="/tmp/claude-stats.pid"

echo $$ > "$PIDFILE"

fetch_usage() {
    local creds token response now

    # macOS: keychain; Linux: flat credentials file
    if command -v security &>/dev/null; then
        creds=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null) || return 1
    elif [ -f "$HOME/.claude/.credentials.json" ]; then
        creds=$(cat "$HOME/.claude/.credentials.json" 2>/dev/null) || return 1
    else
        return 1
    fi

    token=$(printf '%s' "$creds" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
    [ -z "$token" ] && return 1

    response=$(curl -s --max-time 10 \
        -H "Authorization: Bearer $token" \
        -H "anthropic-beta: oauth-2025-04-20" \
        -H "User-Agent: claude-code/2.1" \
        "https://api.anthropic.com/api/oauth/usage" 2>/dev/null) || return 1

    # Only update cache on successful API response (has five_hour field)
    printf '%s' "$response" | jq -e '.five_hour' > /dev/null 2>&1 || return 1

    now=$(date +%s)

    printf '%s' "$response" | jq --argjson now "$now" '{
        five_hour: (if .five_hour.utilization then (.five_hour.utilization | round) else null end),
        seven_day: (if .seven_day.utilization then (.seven_day.utilization | round) else null end),
        seven_day_sonnet: (if .seven_day_sonnet.utilization then (.seven_day_sonnet.utilization | round) else null end),
        seven_day_opus: (if .seven_day_opus.utilization then (.seven_day_opus.utilization | round) else null end),
        seven_day_cowork: (if .seven_day_cowork.utilization then (.seven_day_cowork.utilization | round) else null end),
        updated_at: $now
    }' > "$CACHE_TMP" 2>/dev/null && mv "$CACHE_TMP" "$CACHE_FILE"
}

while true; do
    fetch_usage
    sleep "$INTERVAL"
done
