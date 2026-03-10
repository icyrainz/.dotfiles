#!/usr/bin/env python3
"""Compare two Reddit thread JSON snapshots and output meaningful changes."""

import json
import sys


def extract_post(data):
    p = data[0]["data"]["children"][0]["data"]
    return {
        "score": p["score"],
        "num_comments": p["num_comments"],
        "ratio": p.get("upvote_ratio", 0),
    }


def extract_comments(data, result=None, depth=0):
    if result is None:
        result = {}
    for child in data:
        if child["kind"] != "t1":
            continue
        d = child["data"]
        cid = d["id"]
        result[cid] = {
            "id": cid,
            "author": d.get("author", "[deleted]"),
            "score": d.get("score", 0),
            "body": d.get("body", "").strip(),
            "is_op": d.get("is_submitter", False),
            "depth": depth,
            "stickied": d.get("stickied", False),
        }
        replies = d.get("replies", "")
        if isinstance(replies, dict):
            extract_comments(replies["data"]["children"], result, depth + 1)
    return result


def main():
    old_data = json.loads(sys.argv[1])
    new_data = json.loads(sys.argv[2])

    old_post = extract_post(old_data)
    new_post = extract_post(new_data)
    old_comments = extract_comments(old_data[1]["data"]["children"])
    new_comments = extract_comments(new_data[1]["data"]["children"])

    changes = []

    # Post score change
    score_diff = new_post["score"] - old_post["score"]
    if abs(score_diff) >= 3:
        sign = "+" if score_diff > 0 else ""
        changes.append(
            f"POST: {old_post['score']} -> {new_post['score']} pts ({sign}{score_diff})"
        )

    # Comment count
    comment_diff = new_post["num_comments"] - old_post["num_comments"]
    if comment_diff > 0:
        changes.append(
            f"COMMENTS: {old_post['num_comments']} -> {new_post['num_comments']} (+{comment_diff})"
        )

    # New comments
    new_ids = set(new_comments.keys()) - set(old_comments.keys())
    for cid in new_ids:
        c = new_comments[cid]
        if c["stickied"]:
            continue
        indent = "  " * c["depth"]
        op_tag = " (OP)" if c["is_op"] else ""
        body_preview = c["body"][:200]
        changes.append(
            f"NEW: {indent}u/{c['author']}{op_tag} ({c['score']} pts): {body_preview}"
        )

    # Significant score changes on existing comments (>= 5 point swing)
    for cid in set(old_comments.keys()) & set(new_comments.keys()):
        old_score = old_comments[cid]["score"]
        new_score = new_comments[cid]["score"]
        diff = new_score - old_score
        if abs(diff) >= 5:
            c = new_comments[cid]
            op_tag = " (OP)" if c["is_op"] else ""
            sign = "+" if diff > 0 else ""
            changes.append(
                f"SCORE: u/{c['author']}{op_tag} {old_score} -> {new_score} ({sign}{diff})"
            )

    if changes:
        for line in changes:
            print(line)
    else:
        print("NO_CHANGES")


if __name__ == "__main__":
    main()
