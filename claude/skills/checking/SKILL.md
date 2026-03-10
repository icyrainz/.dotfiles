---
name: checking
description: "Monitor a URL for changes in the background and notify the user when something new happens. Use when the user says /checking, 'monitor this', 'watch for changes', 'keep checking', 'notify me of updates', or 'check for new stuff'. Also use when the user says '/checking stop' to stop monitoring. Works with Reddit threads, web pages, or any fetchable URL. Detects the source type automatically."
---

# URL Change Monitor

Watch a URL in the background and notify the user when something changes.

## Usage

```
/checking <url>              # Start monitoring (default: every 5 min)
/checking <url> every 10m    # Custom interval
/checking stop               # Stop monitoring
```

## Interval

Default interval is **5 minutes**. The user can specify a custom interval with natural language like "every 10m", "every 30s", "every 1h". Parse this into seconds for the `sleep` command. Some examples:
- "every 30s" → `sleep 30`
- "every 2m" → `sleep <interval>`
- "every 10m" → `sleep 600`
- "every 1h" → `sleep 3600`

If the user says the interval is too fast/slow mid-session, adjust on the next cycle.

## Source detection and diffing

For **Reddit** (`reddit.com`), use the smart diff script which compares by comment ID (not text position):
```bash
bash ~/.claude/skills/reddit/scripts/diff_thread.sh "<url>" /tmp/checking_baseline.json
```
This script:
- Stores raw JSON as baseline (not rendered markdown)
- Compares comment sets by ID — immune to Reddit re-sorting comments
- Only reports: new comments, significant score changes (>=5 pts), post score jumps (>=3 pts)
- Outputs `NO_CHANGES` when nothing meaningful changed
- Automatically updates the baseline after each comparison

For **other URLs**, fall back to text diffing:
```bash
curl -sS -L -A "Mozilla/5.0" --max-time 15 "<url>" | python3 -c "import sys; text=sys.stdin.read(); print(text[:5000])"
```

## How to start monitoring

1. Create the baseline (first run of diff_thread.sh does this automatically):
   ```bash
   bash ~/.claude/skills/reddit/scripts/diff_thread.sh "<url>" /tmp/checking_baseline.json
   ```

2. Launch the first check cycle as a background task:
   ```bash
   sleep <interval> && bash ~/.claude/skills/reddit/scripts/diff_thread.sh "<url>" /tmp/checking_baseline.json
   ```
   Run with `run_in_background: true`.

3. Tell the user monitoring is active.

4. Keep track of the URL and that monitoring is active so you can chain the next cycle.

## Chain pattern — this is how monitoring works

Background tasks only notify you when they **complete**. An infinite `while true` loop never completes, so you'd never get notified. Instead, use a chain pattern:

1. Launch a single background task: `sleep <interval> && diff_thread.sh`
2. When it completes, you get notified automatically
3. Read the output — notify the user if there are NEW or SCORE lines
4. Launch the next cycle (go back to step 1)

The diff script handles baseline updates internally — no need to manually copy files.

Stop chaining when:
- The user says `/checking stop` or "stop monitoring"
- The user starts a completely different task and monitoring is no longer relevant

## Interpreting diff output

The diff script outputs structured lines:
- `BASELINE_CREATED` — first run, no comparison yet
- `NO_CHANGES` — nothing meaningful changed, silently chain next cycle
- `POST: 54 -> 62 pts (+8)` — post score changed significantly
- `COMMENTS: 30 -> 33 (+3)` — new comments added
- `NEW: u/someone (2 pts): comment text here` — a new comment with preview
- `SCORE: u/someone 3 -> 15 (+12)` — existing comment had big score swing

Only notify the user when there are NEW or meaningful SCORE/POST lines. For `NO_CHANGES`, just silently chain the next cycle.

When notifying the user, always start with a timestamp so they can orient when the update happened:
```
**[10:42 PM]** 86 pts, 41 comments. New:
- u/someone: "their comment"
```
Use the local time from `date` command output.

## How to stop monitoring

When the user says `/checking stop` or "stop monitoring":
- If a background check is running, stop it with TaskStop
- Do not launch the next cycle
- Confirm to the user that monitoring has stopped
