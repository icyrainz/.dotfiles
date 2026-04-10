---
name: codex-review
description: Ask Codex to review specific files, features, or directories — not just git diffs. Use when user says /codex-review, "codex review this file", "ask codex to review", or wants Codex to review arbitrary code.
argument-hint: "<file paths, glob patterns, or feature description> [--wait|--background]"
---

# Codex File & Feature Review

Review arbitrary files through Codex, not limited to git diffs. Accepts file paths, glob patterns, directories, or feature descriptions.

Raw slash-command arguments:
`$ARGUMENTS`

## Core constraint

- This is review-only. Do not fix issues, apply patches, or make changes.
- Return Codex's output verbatim to the user.

## Step 1: Parse arguments

Strip execution flags from `$ARGUMENTS`:
- `--wait` → force foreground
- `--background` → force background

Call the remaining text `TARGET`.

If `TARGET` is empty, ask the user what to review.

## Step 2: Resolve files

Try to resolve `TARGET` into a file list. Use these strategies in order:

### A. Direct file paths
If `TARGET` contains tokens with path separators (`/`) or file extensions (`.py`, `.ts`, `.fish`, `.yaml`, `.sh`, `.lua`, `.conf`, etc.):
- Check each token with `ls` or `Glob`
- If it's an existing file → add to list
- If it's a directory → expand with `Glob` to get files inside (one level deep)
- If it's a glob pattern (contains `*`, `?`, `**`) → expand with `Glob`

### B. Feature description
If no files resolved from step A, treat `TARGET` as a feature description:
1. Use `Grep` to search for keywords across the codebase
2. Use `Glob` to find files with related names
3. Collect up to 20 most relevant files
4. If still nothing found, tell the user and ask them to be more specific. Stop here.

### C. Show the user what you found
Before proceeding, briefly list the resolved files (just paths, no content). If there are more than 10, summarize by directory.

## Step 3: Execution mode

- If `--wait` was present → foreground, no prompt
- If `--background` was present → background, no prompt
- If <=3 files → recommend foreground
- If >3 files → recommend background
- Use `AskUserQuestion` once with two options, recommended first with `(Recommended)` suffix:
  - `Wait for results`
  - `Run in background`

## Step 4: Build review prompt

Construct this prompt, replacing placeholders:

```
Review the following files for code quality, bugs, security issues, and adherence to this repository's conventions and patterns.

Files to review:
- <file1>
- <file2>
- ...

For each file, check:
1. Material bugs or logic errors
2. Security vulnerabilities
3. Performance issues
4. Convention violations relative to the rest of the codebase
5. Design concerns

Rules:
- Only report material findings. Skip style nitpicks and minor naming feedback.
- For each finding: file path, line number(s), what the issue is, and a concrete recommendation.
- If a file looks clean, say so in one line and move on.
```

If `TARGET` included focus text beyond the file paths (e.g., `src/auth.ts focus on security`), append: `Focus area: <focus text>`.

## Step 5: Run Codex

Write the prompt to a temp file and call `task` in read-only mode (no `--write`).

Resolve the codex companion script path:
```bash
CODEX_SCRIPT="$(ls -d ~/.claude/plugins/cache/openai-codex/codex/*/scripts/codex-companion.mjs 2>/dev/null | sort -V | tail -1)"
```

If `CODEX_SCRIPT` is empty, tell the user Codex is not installed and suggest `/codex:setup`. Stop here.

### Foreground

```bash
CODEX_SCRIPT="$(ls -d ~/.claude/plugins/cache/openai-codex/codex/*/scripts/codex-companion.mjs 2>/dev/null | sort -V | tail -1)"
cat > /tmp/codex-file-review-prompt.txt << 'PROMPT_EOF'
<constructed review prompt>
PROMPT_EOF
node "$CODEX_SCRIPT" task --prompt-file /tmp/codex-file-review-prompt.txt
```

Return stdout verbatim. No paraphrasing or commentary.

### Background

```typescript
Bash({
  command: `CODEX_SCRIPT="$(ls -d ~/.claude/plugins/cache/openai-codex/codex/*/scripts/codex-companion.mjs 2>/dev/null | sort -V | tail -1)" && cat > /tmp/codex-file-review-prompt.txt << 'PROMPT_EOF'\n<constructed review prompt>\nPROMPT_EOF\nnode "$CODEX_SCRIPT" task --prompt-file /tmp/codex-file-review-prompt.txt`,
  description: "Codex file review",
  run_in_background: true
})
```

Tell the user: "Codex file review started in the background. Check `/codex:status` for progress."
