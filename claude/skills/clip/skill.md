---
name: clip
description: Copy AI-generated text to the user's clipboard. Use when the user types "/clip" to copy the most relevant command, query, or code snippet from the conversation so they can paste it in another terminal, DataGrip, etc.
user_invocable: true
---

# clip

Copy the most relevant text from the conversation to the user's system clipboard.

## Behavior

1. Identify the most relevant code block, command, query, or snippet from recent conversation.
2. If multiple candidates, pick the most recent or most contextually relevant one.
3. Copy the raw text (no markdown fences, no extra formatting) to the clipboard.
4. Confirm with a code block showing what was copied.

## Clipboard command

```bash
printf '%s' '<text>' | pbcopy
```

For multi-line content, use a heredoc:

```bash
pbcopy <<'CLIP'
<text>
CLIP
```

## Output format

After copying, respond with:

````
Copied to clipboard:
```<language>
<the copied text>
```
````

Where `<language>` is the appropriate syntax highlight (sql, bash, python, etc.), or omit it for plain text.

## Rules

- Only copy raw content — no markdown fences, no line numbers, no commentary.
- If no obvious candidate, ask the user what they want clipped.
- Copy exactly what was generated — do not modify the text.
