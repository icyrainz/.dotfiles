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

Uses evenly spaced vertical blocks — positions 1, 2, 4, 6, 8, 9 from the full `█ ▇ ▆ ▅ ▄ ▃ ▂ ▁` set (removing 3rd, 5th, 7th for visual distinctness):

| Time remaining | Char |
|---|---|
| 25m – 30m | `█` |
| 20m – 25m | `▇` |
| 15m – 20m | `▅` |
| 10m – 15m | `▃` |
| 5m – 10m | `▁` |
| 0 – 5m | `⠀` (empty) |

The character-type switch (braille → block) itself signals you're in the final 30 minutes.

## Architecture: Daemon vs Renderer Responsibilities

The daemon (`daemon.sh`) owns all API-to-cache transformation. The renderer (`status.sh`) owns all cache-to-display transformation. No mixing.

- **Daemon:** fetches raw API response, transforms data (rounds floats to ints, converts ISO 8601 to epoch seconds), writes cache JSON
- **Cache:** stores only transformed data values — never display characters or formatting
- **Renderer:** reads cache, computes time-dependent values (remaining seconds), maps to display characters, applies tmux color formatting

Performance impact of render-time character selection is negligible (~1-2ms of integer arithmetic on top of existing ~10ms).

## Changes Required

### 1. daemon.sh — Cache reset time

Add `five_hour_resets_at` to the cached JSON. Extract from the API response field `five_hour.resets_at` (ISO 8601 timestamp). Convert to epoch seconds during caching (consistent with how utilization floats are rounded to ints).

```json
{
  "five_hour": 4,
  "five_hour_resets_at": 1775658000,
  "seven_day": 86,
  ...
}
```

All values in the cache are daemon-transformed to their most useful numeric form. The renderer never parses raw API formats.

### 2. status.sh — New `%5r` template variable

- Read `five_hour_resets_at` from cache (epoch seconds)
- Compute `remaining = resets_at - now` (seconds)
- Map remaining seconds to the appropriate braille or block character using the mapping tables above
- If `resets_at` is missing or in the past, show empty braille `⠀`
- Apply color based on the current `five_hour` utilization value against the warn/crit thresholds (same logic as `%5h`). Below warn: default fg. At warn: `#e5c07b`. At crit: `#e06c75`.

Add `%5r` to the template parser alongside the existing variables. The `%5r` variable does not accept inline `{warn,crit}` thresholds — it reads the `five_hour` value and applies the default warn/crit thresholds from the plugin config.

### 3. claude-stats.tmux — Update default format

Change the default format from `%5h{60,90}✦` to `%5h{60,90}✦%5r`.

### 4. README.md — Document `%5r`

Add `%5r` to the format template variables table with description: "5-hour reset countdown (braille dots + block elements)".
