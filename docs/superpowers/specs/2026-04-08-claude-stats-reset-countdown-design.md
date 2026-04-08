# tmux-claude-stats: Reset Countdown

## Summary

Add a visual countdown character to the tmux-claude-stats plugin that shows time remaining until the 5-hour rate limit window resets. Uses braille dots for the macro view (30 min/dot) and vertical block elements for the final 30 minutes (5 min/step). Always visible alongside the existing utilization percentage.

## Display

Format: `04✦⣿` — utilization number, icon, countdown character.

- Template variable: `%5r` (5-hour reset countdown)
- Default format changes from `%5h{60,90}✦` to `%5h{60,90}✦%5r`
- Countdown character color inherits the same threshold coloring as the utilization number (default/yellow at 60%/red at 90%)

## Countdown Character Mapping

### Braille phase (>= 30 min remaining, 30 min per dot)

| Time remaining | Char | Dots filled |
|---|---|---|
| > 4h00m | `⣿` | 8/8 |
| 3h30m – 4h00m | `⣷` | 7/8 |
| 3h00m – 3h30m | `⣶` | 6/8 |
| 2h30m – 3h00m | `⣦` | 5/8 |
| 2h00m – 2h30m | `⣤` | 4/8 |
| 1h30m – 2h00m | `⣄` | 3/8 |
| 1h00m – 1h30m | `⣀` | 2/8 |
| 0h30m – 1h00m | `⢀` | 1/8 |

### Block phase (< 30 min remaining, 5 min per step)

| Time remaining | Char |
|---|---|
| 25m – 30m | `█` |
| 20m – 25m | `▇` |
| 15m – 20m | `▆` |
| 10m – 15m | `▄` |
| 5m – 10m | `▂` |
| 0 – 5m | `▁` |

The character-type switch (braille → block) itself signals you're in the final 30 minutes.

## Changes Required

### 1. daemon.sh — Cache reset time

Add `five_hour_resets_at` to the cached JSON. Extract from the API response field `five_hour.resets_at` (ISO 8601 timestamp). Convert to epoch seconds for easy comparison in the status script.

```json
{
  "five_hour": 4,
  "five_hour_resets_at": 1775658000,
  "seven_day": 86,
  ...
}
```

### 2. status.sh — New `%5r` template variable

- Read `five_hour_resets_at` from cache
- Compute `remaining = resets_at - now` (seconds)
- Convert remaining seconds to the appropriate braille or block character using the mapping table
- If `resets_at` is missing or in the past, show the empty braille `⠀`
- Apply color based on the current `five_hour` utilization value against the warn/crit thresholds (same logic as `%5h`). Below warn: default fg. At warn: `#e5c07b`. At crit: `#e06c75`.

Add `%5r` to the template parser alongside the existing variables. The `%5r` variable does not accept inline `{warn,crit}` thresholds — it reads the `five_hour` value and applies the default warn/crit thresholds from the plugin config.

### 3. claude-stats.tmux — Update default format

Change the default format from `%5h{60,90}✦` to `%5h{60,90}✦%5r`.

### 4. README.md — Document `%5r`

Add `%5r` to the format template variables table with description: "5-hour reset countdown (braille dots + block elements)".
