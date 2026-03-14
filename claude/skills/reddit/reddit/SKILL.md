---
name: reddit
description: "Use when reading, summarizing, or discussing Reddit threads. Invoke via /reddit <url> or whenever a user pastes a Reddit link. Fetches the full post and comments via Reddit's JSON API (bypassing blocks on web search/fetch), loads the content into context, and enables conversation about the thread. Use this skill whenever a user shares a Reddit URL, mentions a Reddit discussion they want to read, or asks about content from a specific Reddit thread."
---

# Reddit Thread Reader

Fetch a Reddit thread's post and comments, then enable informed conversation about it.

## Step 1: Run the fetch script

```bash
python3 ~/.claude/skills/reddit/scripts/fetch_thread.py "URL"
```

The script accepts any Reddit URL format — `www.reddit.com`, `old.reddit.com`, `redd.it` short links, `np.reddit.com`, etc. It fetches the post and top comments via Reddit's public JSON API with a custom user-agent (which Reddit allows, unlike browser-blocked web fetches).

Optional flags:
- `--comments N` — number of top-level comments to fetch (default: 200)
- `--depth D` — reply nesting depth (default: 10)

Parse stdout for:
- `POST_ID` — Reddit post identifier
- `SUBREDDIT` — the subreddit (e.g., `r/selfhosted`)
- `TITLE` — post title
- `AUTHOR` — post author
- `SCORE` — post score
- `NUM_COMMENTS` — total comment count
- `THREAD_FILE` — path to the full thread text file
- `THREAD_LENGTH` — character count
- `PERMALINK` — full URL to the thread

If the script fails, check stderr — it reports rate limits (429), forbidden (403), not found (404), and URL parse errors.

## Step 2: Load and present

Read `THREAD_FILE`. Present to the user:

---

**Thread:** [title]
**Subreddit:** [subreddit] | **Score:** [score] | **Comments:** [num_comments]

**Summary:**
[3-5 bullet points capturing the main discussion points from the post AND top comments — not just the post itself]

---

I've loaded this Reddit thread. Ask me anything about the discussion.

---

## Conversation Guidelines

When discussing the thread:

- **Reference specific commenters** when relevant (e.g., "u/example argues that...")
- **Note comment scores** to convey community consensus vs. minority opinions
- **Distinguish OP's post from comments** — the post sets the topic, comments are the discussion
- **Flag deleted/removed content** rather than guessing what it said
- **Note when comments are truncated** — if the thread has 500 comments but only 200 were fetched, mention this when asked about consensus
