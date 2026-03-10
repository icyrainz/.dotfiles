---
name: reddit
description: "Use when the user passes a Reddit thread URL and wants to discuss, analyze, or monitor the conversation. Invoke via /reddit <url>. Fetches the full thread (post + comments), formats it concisely, and loads it into context for discussion. Also use when the user says 'refresh the thread', 'check for new comments', or 'update the reddit thread' to re-fetch and show what changed. Use this skill whenever a Reddit URL appears and the user wants to engage with the content."
---

# Reddit Thread Loader

Load a Reddit thread into context for discussion, analysis, and monitoring.

## Usage

```
/reddit <url>              # Load a thread
/reddit refresh            # Re-fetch the current thread to see new comments
/reddit <different-url>    # Switch to a different thread
```

## How it works

1. Run the fetch script to pull the thread:
   ```bash
   bash SKILL_DIR/scripts/fetch_reddit.sh "<url>"
   ```
   Replace `SKILL_DIR` with the actual path to this skill's directory.

2. The script outputs a concise markdown summary: post title, metadata, body, and all comments threaded with indentation. Display this output to the user so they can see the current state of the discussion.

3. After loading, the user can ask questions, draft replies, analyze sentiment, or just chat about the thread. Keep track of the URL so "refresh" works without the user repeating it.

## Refreshing

When the user says "refresh", "update", or "check for new comments":
- Re-run the fetch script with the same URL
- Compare with the previous fetch and highlight what's new (new comments, score changes)
- If nothing changed, say so briefly

## Formatting principles

- The script already formats things concisely — don't reformat or summarize unless asked
- When discussing specific comments, reference them by username (e.g. "u/username's comment about...")
- Keep your own responses short — the user is here to discuss, not read walls of text
