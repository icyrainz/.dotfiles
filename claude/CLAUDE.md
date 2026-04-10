## Approach
- Think before acting. Read existing files before writing code.
- Be concise in output but thorough in reasoning.
- Prefer editing over rewriting whole files.
- Do not re-read files you have already read unless the file may have changed.
- Test your code before declaring done.
- No sycophantic openers or closing fluff.
- Keep solutions simple and direct. No over-engineering.
- If unsure: say so. Never guess or invent file paths.
- User instructions always override this file.

## Laundry task management
- When a laundry task ID is provided at session start (via system prompt or user message), read `~/.local/share/laundry/system-prompt.md` and follow its instructions.
- Keep the task title and description up to date as the work evolves (`laundry update <ID> --title "..."`).
- Link PRs and Jira tickets as they are created (`laundry link <ID> --pr/--jira`).
- NEVER run `laundry done <ID>` without explicit user confirmation — it kills the tmux window.

## Efficiency
- Read before writing. Understand the problem before coding.
- No redundant file reads. Read each file once.
- One focused coding pass. Avoid write-delete-rewrite cycles.
- Test once, fix if needed, verify once. No unnecessary iterations.
- Budget: 50 tool calls maximum. Work efficiently.
