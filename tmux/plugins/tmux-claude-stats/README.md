# tmux-claude-stats

Tmux plugin that displays Claude Code API usage/rate limits in your status bar.

Shows 5-hour and 7-day utilization percentages with color-coded thresholds (green → yellow → red).

## Requirements

- macOS (uses `security` keychain for OAuth token)
- `jq`, `curl`
- [TPM](https://github.com/tmux-plugins/tpm)

## Install

Add to your `tmux.conf`:

```tmux
set -g @plugin 'icyrainz/tmux-claude-stats'
```

Then press `prefix + I` to install.

## Usage

Add `#{claude_stats}` to your status bar:

```tmux
set -g status-right '#{claude_stats}'
```

## Configuration

| Option | Default | Description |
|---|---|---|
| `@claude-stats-format` | `%5h{60,90}✦` | Display format template |
| `@claude-stats-interval` | `300` | API poll interval (seconds) |
| `@claude-stats-warn` | `60` | Default warn threshold (%) |
| `@claude-stats-crit` | `90` | Default critical threshold (%) |

### Format template variables

| Variable | Description |
|---|---|
| `%5h` | 5-hour utilization |
| `%7d` | 7-day overall utilization |
| `%7ds` | 7-day Sonnet utilization |
| `%7do` | 7-day Opus utilization |
| `%7dc` | 7-day cowork utilization |
| `%%` | Literal `%` |

Each variable accepts optional inline thresholds: `%5h{60,90}` (warn at 60%, critical at 90%).

### Example formats

```tmux
# 5-hour only with icon (default)
set -g @claude-stats-format '%5h{60,90}✦'

# 5-hour and 7-day
set -g @claude-stats-format '%5h{60,90}/%7d{60,90}✦'

# All breakdowns
set -g @claude-stats-format '5h:%5h 7d:%7d s:%7ds o:%7do'
```

## How it works

A background daemon polls the Claude API every 5 minutes (configurable) and caches results to `/tmp/claude-stats.json`. The status script reads the cache and formats it for tmux — no API calls in the render path.

## License

MIT
