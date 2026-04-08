# Claude Stats Reset Countdown Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a visual braille/block countdown character to tmux-claude-stats showing time until 5-hour rate limit window resets.

**Architecture:** The daemon caches `resets_at` as epoch seconds alongside existing utilization data. The renderer computes time remaining at display time and maps it to a braille character (>= 30 min) or vertical block character (< 30 min). New `%5r` template variable slots into the existing format parser.

**Tech Stack:** Bash, jq, tmux plugin API

**Spec:** `docs/superpowers/specs/2026-04-08-claude-stats-reset-countdown-design.md`

---

## File Map

| File | Action | Responsibility |
|---|---|---|
| `tmux/plugins/tmux-claude-stats/scripts/daemon.sh` | Modify | Add `five_hour_resets_at` to cached JSON |
| `tmux/plugins/tmux-claude-stats/scripts/status.sh` | Modify | Add `%5r` countdown character rendering |
| `tmux/plugins/tmux-claude-stats/claude-stats.tmux` | Modify | Update default format to include `%5r` |
| `tmux/plugins/tmux-claude-stats/README.md` | Modify | Document `%5r` variable |

---

### Task 1: Cache `resets_at` in daemon.sh

**Files:**
- Modify: `tmux/plugins/tmux-claude-stats/scripts/daemon.sh:30-37`

- [ ] **Step 1: Add `five_hour_resets_at` to the jq cache transform**

The daemon's `fetch_usage` function builds the cache JSON via jq. Add extraction of `five_hour.resets_at`, converting ISO 8601 to epoch seconds.

In `daemon.sh`, replace the jq pipeline (lines 30-37):

```bash
    printf '%s' "$response" | jq --argjson now "$now" '{
        five_hour: (if .five_hour.utilization then (.five_hour.utilization | round) else null end),
        five_hour_resets_at: (if .five_hour.resets_at then (.five_hour.resets_at | sub("\\.[0-9]+.*$"; "Z") | fromdateiso8601) else null end),
        seven_day: (if .seven_day.utilization then (.seven_day.utilization | round) else null end),
        seven_day_sonnet: (if .seven_day_sonnet.utilization then (.seven_day_sonnet.utilization | round) else null end),
        seven_day_opus: (if .seven_day_opus.utilization then (.seven_day_opus.utilization | round) else null end),
        seven_day_cowork: (if .seven_day_cowork.utilization then (.seven_day_cowork.utilization | round) else null end),
        updated_at: $now
    }' > "$CACHE_TMP" 2>/dev/null && mv "$CACHE_TMP" "$CACHE_FILE"
```

The `sub("\\.[0-9]+.*$"; "Z") | fromdateiso8601` strips fractional seconds and timezone offset, then converts to epoch. jq's `fromdateiso8601` expects the `Z` suffix.

- [ ] **Step 2: Verify the daemon caches the new field**

Kill existing daemon and run one fetch cycle manually:

```bash
kill "$(cat /tmp/claude-stats.pid)" 2>/dev/null
bash tmux/plugins/tmux-claude-stats/scripts/daemon.sh 99999 &
sleep 5
cat /tmp/claude-stats.json | jq .
kill %1
```

Expected: JSON output includes `five_hour_resets_at` as an integer (epoch seconds), e.g.:

```json
{
  "five_hour": 4,
  "five_hour_resets_at": 1775658000,
  "seven_day": 86,
  ...
}
```

- [ ] **Step 3: Commit**

```bash
git add tmux/plugins/tmux-claude-stats/scripts/daemon.sh
git commit -m "claude-stats: cache five_hour_resets_at in daemon"
```

---

### Task 2: Add countdown character rendering to status.sh

**Files:**
- Modify: `tmux/plugins/tmux-claude-stats/scripts/status.sh`

- [ ] **Step 1: Read `five_hour_resets_at` from cache**

After the existing cache value reads (after line 52), add:

```bash
five_hour_resets_at=$(printf '%s' "$cache" | jq -r '.five_hour_resets_at // "null"')
```

- [ ] **Step 2: Add the `resets_char` function**

Add this function after the `format_value` function (after line 83). It takes the `resets_at` epoch and `five_hour` utilization value, and returns the appropriate character with color.

```bash
resets_char() {
    local resets_at="$1" warn="${2:-$DEFAULT_WARN}" crit="${3:-$DEFAULT_CRIT}"
    local now char

    now=$(date +%s)

    if [ "$resets_at" = "null" ] || [ "$resets_at" -le "$now" ] 2>/dev/null; then
        printf '⠀'
        return
    fi

    local remaining=$(( resets_at - now ))
    local minutes=$(( remaining / 60 ))

    # Block phase: < 30 min, 5 min per step, evenly spaced blocks
    if [ "$minutes" -lt 5 ]; then
        char="⠀"
    elif [ "$minutes" -lt 10 ]; then
        char="▁"
    elif [ "$minutes" -lt 15 ]; then
        char="▃"
    elif [ "$minutes" -lt 20 ]; then
        char="▅"
    elif [ "$minutes" -lt 25 ]; then
        char="▇"
    elif [ "$minutes" -lt 30 ]; then
        char="█"
    # Braille phase: >= 30 min, 30 min per dot
    elif [ "$minutes" -lt 60 ]; then
        char="⢀"
    elif [ "$minutes" -lt 90 ]; then
        char="⣀"
    elif [ "$minutes" -lt 120 ]; then
        char="⣄"
    elif [ "$minutes" -lt 150 ]; then
        char="⣤"
    elif [ "$minutes" -lt 180 ]; then
        char="⣦"
    elif [ "$minutes" -lt 210 ]; then
        char="⣶"
    elif [ "$minutes" -lt 240 ]; then
        char="⣷"
    else
        char="⣿"
    fi

    # Apply color based on five_hour utilization (same as %5h)
    if [ "$five_hour" != "null" ] && [ "$five_hour" -ge "$crit" ] 2>/dev/null; then
        printf '#[fg=%s]%s#[fg=default]' "$COLOR_CRIT" "$char"
    elif [ "$five_hour" != "null" ] && [ "$five_hour" -ge "$warn" ] 2>/dev/null; then
        printf '#[fg=%s]%s#[fg=default]' "$COLOR_WARN" "$char"
    else
        printf '%s' "$char"
    fi
}
```

- [ ] **Step 3: Wire `%5r` into the template parser**

In the template parser's pattern matching loop (line 104), add `5r` to the pattern list. The `5r` pattern is special — it calls `resets_char` instead of `format_value`.

Replace the `for pattern in` line:

```bash
        for pattern in "7ds:seven_day_sonnet" "7do:seven_day_opus" "7dc:seven_day_cowork" "7d:seven_day" "5r:five_hour_reset" "5h:five_hour"; do
```

And inside the match block, after computing `warn` and `crit` from inline thresholds (around line 126-127), replace the single `format_value` call with a conditional:

```bash
                if [ "$field" = "five_hour_reset" ]; then
                    output="${output}$(resets_char "$five_hour_resets_at" "$warn" "$crit")"
                else
                    value=$(get_value "$field")
                    output="${output}$(format_value "$value" "$warn" "$crit")"
                fi
```

- [ ] **Step 4: Verify the countdown renders**

Test with a mock cache to check each phase boundary:

```bash
# Test braille phase: 2 hours remaining → should show ⣄
now=$(date +%s)
resets_at=$((now + 7200))
echo "{\"five_hour\": 4, \"five_hour_resets_at\": $resets_at, \"seven_day\": 50, \"updated_at\": $now}" > /tmp/claude-stats.json
bash tmux/plugins/tmux-claude-stats/scripts/status.sh '%5h{60,90}✦%5r'
echo

# Test block phase: 12 minutes remaining → should show ▃
resets_at=$((now + 720))
echo "{\"five_hour\": 75, \"five_hour_resets_at\": $resets_at, \"seven_day\": 50, \"updated_at\": $now}" > /tmp/claude-stats.json
bash tmux/plugins/tmux-claude-stats/scripts/status.sh '%5h{60,90}✦%5r'
echo

# Test expired: resets_at in the past → should show ⠀
resets_at=$((now - 60))
echo "{\"five_hour\": 4, \"five_hour_resets_at\": $resets_at, \"seven_day\": 50, \"updated_at\": $now}" > /tmp/claude-stats.json
bash tmux/plugins/tmux-claude-stats/scripts/status.sh '%5h{60,90}✦%5r'
echo
```

Expected output (ignoring tmux color codes):
1. `04✦⣄` (braille, 3 dots, default color)
2. `75✦▃` (block, yellow color on both 75 and ▃)
3. `04✦⠀` (empty, past reset)

- [ ] **Step 5: Commit**

```bash
git add tmux/plugins/tmux-claude-stats/scripts/status.sh
git commit -m "claude-stats: add %5r reset countdown character"
```

---

### Task 3: Update default format and entry point

**Files:**
- Modify: `tmux/plugins/tmux-claude-stats/claude-stats.tmux:17`

- [ ] **Step 1: Update default format**

In `claude-stats.tmux` line 17, change:

```bash
format=$(get_tmux_option "@claude-stats-format" '%5h{60,90}✦')
```

to:

```bash
format=$(get_tmux_option "@claude-stats-format" '%5h{60,90}✦%5r')
```

- [ ] **Step 2: Verify end-to-end in tmux**

Restore real cache by restarting the daemon, then reload tmux config:

```bash
kill "$(cat /tmp/claude-stats.pid)" 2>/dev/null
tmux source-file ~/.tmux.conf
```

Check the status bar — should show the utilization number, icon, and a braille countdown character (e.g., `04✦⣿`).

- [ ] **Step 3: Commit**

```bash
git add tmux/plugins/tmux-claude-stats/claude-stats.tmux
git commit -m "claude-stats: update default format to include reset countdown"
```

---

### Task 4: Update README

**Files:**
- Modify: `tmux/plugins/tmux-claude-stats/README.md`

- [ ] **Step 1: Add `%5r` to the format template variables table**

In the format template variables table (after the `%%` row), add:

```markdown
| `%5r` | 5-hour reset countdown (braille dots → block elements) |
```

- [ ] **Step 2: Update the example formats section**

Update the default format example to show `%5r`:

```markdown
# 5-hour with countdown (default)
set -g @claude-stats-format '%5h{60,90}✦%5r'

# 5-hour and 7-day with countdown
set -g @claude-stats-format '%5h{60,90}/%7d{60,90}✦%5r'
```

- [ ] **Step 3: Commit**

```bash
git add tmux/plugins/tmux-claude-stats/README.md
git commit -m "claude-stats: document %5r in README"
```
