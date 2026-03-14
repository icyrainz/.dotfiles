#!/usr/bin/env python3
"""Fetch a Reddit thread (post + comments) via the public JSON API.

Usage:
    python3 fetch_thread.py <reddit_url> [--comments N] [--depth D]

Outputs thread content to /tmp/reddit-<post_id>-thread.txt and prints
metadata fields to stdout for the calling skill to parse.
"""

import json
import re
import sys
import urllib.request
import urllib.error
from datetime import datetime, timezone
from html import unescape
from pathlib import Path

USER_AGENT = "reddit-skill:v1.0 (claude-code skill)"
DEFAULT_COMMENT_LIMIT = 200
DEFAULT_DEPTH = 10


def extract_post_path(url: str) -> str:
    """Extract the /r/sub/comments/id/slug path from various Reddit URL formats."""
    url = url.strip().rstrip("/")

    # Handle redd.it short links by following redirect
    if "redd.it/" in url:
        req = urllib.request.Request(url, method="HEAD")
        req.add_header("User-Agent", USER_AGENT)
        try:
            resp = urllib.request.urlopen(req)
            url = resp.url.rstrip("/")
        except urllib.error.HTTPError as e:
            if e.headers.get("Location"):
                url = e.headers["Location"].rstrip("/")
            else:
                raise

    # Strip domain, keep path
    match = re.search(r"(/r/[^?#]+)", url)
    if match:
        return match.group(1).rstrip("/")

    print("ERROR: Could not parse Reddit URL", file=sys.stderr)
    sys.exit(1)


def fetch_json(path: str, params: dict) -> list:
    """Fetch JSON from Reddit API."""
    query = "&".join(f"{k}={v}" for k, v in params.items())
    api_url = f"https://www.reddit.com{path}.json?{query}"
    req = urllib.request.Request(api_url)
    req.add_header("User-Agent", USER_AGENT)
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read().decode())
    except urllib.error.HTTPError as e:
        if e.code == 429:
            print("ERROR: Rate limited by Reddit. Wait a moment and retry.", file=sys.stderr)
        elif e.code == 403:
            print("ERROR: Reddit returned 403 Forbidden.", file=sys.stderr)
        elif e.code == 404:
            print("ERROR: Thread not found (404).", file=sys.stderr)
        else:
            print(f"ERROR: Reddit returned HTTP {e.code}.", file=sys.stderr)
        sys.exit(1)


def ts_to_date(ts: float) -> str:
    return datetime.fromtimestamp(ts, tz=timezone.utc).strftime("%Y-%m-%d %H:%M UTC")


def clean_text(text: str) -> str:
    """Clean Reddit markdown text."""
    text = unescape(text)
    # Collapse excessive newlines
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()


def format_comment(comment_data: dict, depth: int = 0) -> str:
    """Recursively format a comment and its replies."""
    if comment_data.get("kind") != "t1":
        return ""

    c = comment_data["data"]
    indent = "  " * depth
    author = c.get("author", "[deleted]")
    score = c.get("score", 0)
    body = clean_text(c.get("body", "[removed]"))
    created = ts_to_date(c.get("created_utc", 0))

    # Indent the body
    body_lines = body.split("\n")
    indented_body = "\n".join(f"{indent}  {line}" for line in body_lines)

    lines = [f"{indent}[{score} pts] u/{author} ({created}):"]
    lines.append(indented_body)
    lines.append("")

    # Process replies
    replies = c.get("replies")
    if isinstance(replies, dict):
        children = replies.get("data", {}).get("children", [])
        for child in children:
            lines.append(format_comment(child, depth + 1))

    return "\n".join(lines)


def main():
    if len(sys.argv) < 2:
        print("Usage: fetch_thread.py <reddit_url> [--comments N] [--depth D]", file=sys.stderr)
        sys.exit(1)

    url = sys.argv[1]
    comment_limit = DEFAULT_COMMENT_LIMIT
    depth = DEFAULT_DEPTH

    # Parse optional args
    args = sys.argv[2:]
    for i, arg in enumerate(args):
        if arg == "--comments" and i + 1 < len(args):
            comment_limit = int(args[i + 1])
        elif arg == "--depth" and i + 1 < len(args):
            depth = int(args[i + 1])

    path = extract_post_path(url)
    data = fetch_json(path, {"limit": comment_limit, "depth": depth, "sort": "top"})

    # Extract post
    post = data[0]["data"]["children"][0]["data"]
    post_id = post["id"]
    title = unescape(post.get("title", ""))
    author = post.get("author", "[deleted]")
    subreddit = post.get("subreddit", "")
    score = post.get("score", 0)
    upvote_ratio = post.get("upvote_ratio", 0)
    num_comments = post.get("num_comments", 0)
    created = ts_to_date(post.get("created_utc", 0))
    selftext = clean_text(post.get("selftext", ""))
    post_url = post.get("url", "")
    permalink = f"https://www.reddit.com{post.get('permalink', '')}"
    flair = post.get("link_flair_text", "")
    is_self = post.get("is_self", True)

    # Build output
    out = []
    out.append(f"# {title}")
    out.append("")
    out.append(f"**Subreddit:** r/{subreddit} | **Author:** u/{author} | **Score:** {score} ({upvote_ratio:.0%} upvoted)")
    out.append(f"**Posted:** {created} | **Comments:** {num_comments}")
    if flair:
        out.append(f"**Flair:** {flair}")
    if not is_self and post_url:
        out.append(f"**Link:** {post_url}")
    out.append(f"**Permalink:** {permalink}")
    out.append("")

    if selftext:
        out.append("---")
        out.append("")
        out.append(selftext)
        out.append("")

    # Comments
    comments = data[1]["data"]["children"]
    if comments:
        out.append("---")
        out.append("")
        out.append(f"## Comments (top {min(len(comments), comment_limit)}, sorted by top)")
        out.append("")
        for comment in comments:
            formatted = format_comment(comment)
            if formatted.strip():
                out.append(formatted)

    content = "\n".join(out)

    # Write to file
    out_path = Path(f"/tmp/reddit-{post_id}-thread.txt")
    out_path.write_text(content, encoding="utf-8")

    # Output metadata for skill
    print(f"POST_ID={post_id}")
    print(f"SUBREDDIT=r/{subreddit}")
    print(f"TITLE={title}")
    print(f"AUTHOR=u/{author}")
    print(f"SCORE={score}")
    print(f"NUM_COMMENTS={num_comments}")
    print(f"THREAD_FILE={out_path}")
    print(f"THREAD_LENGTH={len(content)}")
    print(f"PERMALINK={permalink}")


if __name__ == "__main__":
    main()
