#!/usr/bin/env bash
# Claude Code rate limit reader — reads cache, applies template, outputs tmux format
# Args: $1 = format template, $2 = default warn threshold, $3 = default crit threshold

FORMAT="${1:-%5h\{60,90\}✦}"
DEFAULT_WARN="${2:-60}"
DEFAULT_CRIT="${3:-90}"

CACHE_FILE="/tmp/claude-stats.json"
STALE_SECONDS=1800

COLOR_WARN="#e5c07b"
COLOR_CRIT="#e06c75"
COLOR_STALE="#5c6370"

# --- Stale / missing cache ---

extract_trailing_icon() {
    # Replace %% with literal %, then strip all template variables and their optional {w,c} blocks
    # What remains after the last variable is the trailing icon
    printf '%s' "$1" | sed -E 's/%%/%/g; s/%(5h|7d[soc]?|7d)(\{[0-9]+,[0-9]+\})?//g'
}

if [ ! -f "$CACHE_FILE" ]; then
    icon=$(extract_trailing_icon "$FORMAT")
    printf '#[fg=%s]--%s#[fg=default]' "$COLOR_STALE" "$icon"
    exit 0
fi

cache=$(cat "$CACHE_FILE" 2>/dev/null) || {
    icon=$(extract_trailing_icon "$FORMAT")
    printf '#[fg=%s]--%s#[fg=default]' "$COLOR_STALE" "$icon"
    exit 0
}

updated_at=$(printf '%s' "$cache" | jq -r '.updated_at // 0' 2>/dev/null)
now=$(date +%s)
age=$((now - ${updated_at:-0}))

if [ "$age" -gt "$STALE_SECONDS" ] || [ "${updated_at:-0}" = "0" ]; then
    icon=$(extract_trailing_icon "$FORMAT")
    printf '#[fg=%s]--%s#[fg=default]' "$COLOR_STALE" "$icon"
    exit 0
fi

# --- Read all values from cache ---

five_hour=$(printf '%s' "$cache" | jq -r '.five_hour // "null"')
seven_day=$(printf '%s' "$cache" | jq -r '.seven_day // "null"')
seven_day_sonnet=$(printf '%s' "$cache" | jq -r '.seven_day_sonnet // "null"')
seven_day_opus=$(printf '%s' "$cache" | jq -r '.seven_day_opus // "null"')
seven_day_cowork=$(printf '%s' "$cache" | jq -r '.seven_day_cowork // "null"')

get_value() {
    case "$1" in
        five_hour)        printf '%s' "$five_hour" ;;
        seven_day)        printf '%s' "$seven_day" ;;
        seven_day_sonnet) printf '%s' "$seven_day_sonnet" ;;
        seven_day_opus)   printf '%s' "$seven_day_opus" ;;
        seven_day_cowork) printf '%s' "$seven_day_cowork" ;;
    esac
}

format_value() {
    local value="$1" warn="${2:-$DEFAULT_WARN}" crit="${3:-$DEFAULT_CRIT}"

    if [ "$value" = "null" ]; then
        printf '#[fg=%s]--#[fg=default]' "$COLOR_STALE"
        return
    fi

    [ "$value" -ge 99 ] 2>/dev/null && value=99
    local formatted
    formatted=$(printf "%02d" "$value")

    if [ "$value" -ge "$crit" ]; then
        printf '#[fg=%s]%s#[fg=default]' "$COLOR_CRIT" "$formatted"
    elif [ "$value" -ge "$warn" ]; then
        printf '#[fg=%s]%s#[fg=default]' "$COLOR_WARN" "$formatted"
    else
        printf '%s' "$formatted"
    fi
}

# --- Template parser (longest-prefix-first) ---

output=""
i=0
len=${#FORMAT}

while [ "$i" -lt "$len" ]; do
    char="${FORMAT:$i:1}"

    if [ "$char" = "%" ]; then
        # Literal %% → %
        if [ "${FORMAT:$((i+1)):1}" = "%" ]; then
            output="${output}%"
            i=$((i + 2))
            continue
        fi

        # Longest-prefix-first matching
        matched=false
        for pattern in "7ds:seven_day_sonnet" "7do:seven_day_opus" "7dc:seven_day_cowork" "7d:seven_day" "5h:five_hour"; do
            key="${pattern%%:*}"
            field="${pattern#*:}"
            klen=${#key}

            if [ "${FORMAT:$((i+1)):$klen}" = "$key" ]; then
                pos=$((i + 1 + klen))
                warn="$DEFAULT_WARN"
                crit="$DEFAULT_CRIT"

                # Optional inline thresholds {warn,crit}
                if [ "${FORMAT:$pos:1}" = "{" ]; then
                    end=$((pos + 1))
                    while [ "$end" -lt "$len" ] && [ "${FORMAT:$end:1}" != "}" ]; do
                        end=$((end + 1))
                    done
                    thresholds="${FORMAT:$((pos+1)):$((end-pos-1))}"
                    warn="${thresholds%%,*}"
                    crit="${thresholds#*,}"
                    pos=$((end + 1))
                fi

                value=$(get_value "$field")
                output="${output}$(format_value "$value" "$warn" "$crit")"
                i=$pos
                matched=true
                break
            fi
        done

        if [ "$matched" = false ]; then
            output="${output}%"
            i=$((i + 1))
        fi
    else
        output="${output}${char}"
        i=$((i + 1))
    fi
done

printf '%s' "$output"
