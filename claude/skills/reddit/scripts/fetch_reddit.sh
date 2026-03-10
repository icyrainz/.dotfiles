#!/usr/bin/env bash
# Fetches a Reddit thread as JSON and formats it concisely for context loading.
# Usage: fetch_reddit.sh <reddit_url> [output_file]
#
# Accepts any reddit.com thread URL format. Outputs a concise markdown summary
# of the post and all comments, threaded with indentation.

set -euo pipefail

URL="${1:?Usage: fetch_reddit.sh <reddit_url> [output_file]}"
OUTPUT="${2:-}"

# Normalize URL: strip trailing slash, remove query params, ensure .json suffix
CLEAN_URL=$(echo "$URL" | sed 's|/$||; s|?.*||; s|\.json$||')
JSON_URL="${CLEAN_URL}.json"

# Fetch with a browser-like user agent to avoid 429s
RAW=$(curl -sS -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
  --max-time 15 "$JSON_URL" 2>&1)

if [ $? -ne 0 ] || echo "$RAW" | head -1 | grep -q '^<'; then
  echo "ERROR: Failed to fetch thread. URL: $JSON_URL" >&2
  exit 1
fi

# Parse with python (available on macOS by default)
PARSED=$(python3 -c '
import json, sys, textwrap
from datetime import datetime

data = json.loads(sys.stdin.read())

# Post
post = data[0]["data"]["children"][0]["data"]
sub = post["subreddit_name_prefixed"]
title = post["title"]
author = post["author"]
score = post["score"]
ratio = post.get("upvote_ratio", 0)
num_comments = post["num_comments"]
body = post.get("selftext", "").strip()
created = datetime.fromtimestamp(post["created_utc"], tz=__import__("datetime").timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
url = post.get("url", "")

print(f"# {title}")
print(f"**{sub}** | u/{author} | {score} pts ({int(ratio*100)}% upvoted) | {num_comments} comments | {created}")
print()
if body:
    print(body)
    print()

# Comments
def print_comment(c, depth=0):
    if c["kind"] != "t1":
        return
    d = c["data"]
    indent = "  " * depth
    author = d.get("author", "[deleted]")
    score = d.get("score", 0)
    body = d.get("body", "").strip()
    is_op = " (OP)" if d.get("is_submitter") else ""
    stickied = " [stickied]" if d.get("stickied") else ""

    print(f"{indent}---")
    print(f"{indent}**u/{author}**{is_op}{stickied} | {score} pts")
    # Indent body lines
    for line in body.split("\n"):
        print(f"{indent}{line}")
    print()

    replies = d.get("replies", "")
    if isinstance(replies, dict):
        for child in replies["data"]["children"]:
            print_comment(child, depth + 1)

print("## Comments")
print()
comments = data[1]["data"]["children"]
for c in comments:
    print_comment(c)
' <<< "$RAW")

if [ -n "$OUTPUT" ]; then
  echo "$PARSED" > "$OUTPUT"
  echo "Saved to $OUTPUT"
else
  echo "$PARSED"
fi
