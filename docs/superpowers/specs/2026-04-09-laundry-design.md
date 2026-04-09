# Laundry: Task-Driven Claude Workspace Manager

## Summary

A CLI tool (`laundry`) that manages a task list where each task has an associated Claude Code instance running inside a tmux window. Tasks are the unit of work — they can be vague ideas or specific subtasks. Claude instances self-manage their task state via the `laundry` CLI. A television channel provides a fuzzy picker (`prefix+f`) to browse and jump across tasks.

## Mental Model

Current: tmux sessions are per-repo, Claude instances are discovered by scanning panes.

New: a **task list** is the primary interface. Each task maps to a tmux window (inside the session for its repo). `prefix+f` shows tasks, not panes. Jumping to a task lands you in the tmux window where Claude is working on it.

Tasks start vague, get refined through conversation with Claude, and can be broken down into subtasks that feed back into the same list.

## Data Model

### Storage layout

```
~/.local/share/laundry/
├── tasks.json                          # structured index, sole source of truth
└── notes/
    ├── 003-fix-auth-token-expiry.md    # freeform task log (mini PROGRESS.md)
    └── 004-handle-refresh-tokens.md
```

### Task schema (`tasks.json`)

```json
{
  "version": 1,
  "next_id": 4,
  "tasks": [
    {
      "id": 3,
      "title": "Fix auth token expiry in provider-service",
      "description": "Refresh tokens aren't being rotated when the upstream provider returns a 401. Investigate token_cache.py and the retry middleware.",
      "status": "active",
      "parent_id": null,
      "project": "/Users/tue.phan/Code/provider-service",
      "tmux_window_id": "@42",
      "claude_session_id": "abc-123-def",
      "links": {
        "prs": ["org/repo#42", "org/repo#45"],
        "jira": ["PROJ-123"]
      },
      "notes_file": "003-fix-auth-token-expiry.md",
      "created_at": "2026-04-09T10:00:00Z",
      "updated_at": "2026-04-09T14:30:00Z"
    }
  ]
}
```

Non-project tasks default to `~/.dotfiles` as project and land in the `dotfiles` tmux session.

### Notes file

Freeform markdown per task. Claude writes findings, decisions, and progress here. The `laundry note` command appends timestamped entries. The file also serves as the tv preview content.

```markdown
# Fix auth token expiry

## 2026-04-09 10:15
Found root cause: token_cache.py line 42 doesn't check expiry before reuse.

## 2026-04-09 11:30
PR created: org/repo#42 — fixes the cache check.
Waiting on CI.
```

## Task States

```
pending     no tmux window, no Claude. Task is just a list entry.
active      tmux window exists, Claude running or waiting for input.
paused      tmux window killed, Claude session ID preserved. Work not done.
completed   done. Window killed, session ended.
cancelled   abandoned. Same cleanup as completed.
```

### State transitions

```
pending   → active       laundry open <id>     creates window + launches Claude
pending   → cancelled    laundry cancel <id>

active    → paused       laundry pause <id>    kills window, saves session ID
active    → completed    laundry done <id>     kills window
active    → cancelled    laundry cancel <id>   kills window

paused    → active       laundry open <id>     creates window + claude --resume
paused    → cancelled    laundry cancel <id>
```

No backwards transitions. To reopen completed work, create a new task.

## CLI Interface

Single Python file, no pip dependencies (stdlib only: `json`, `argparse`, `subprocess`, `pathlib`, `datetime`).

```bash
# Create
laundry add "Fix auth expiry" --project ~/Code/provider-service
laundry add "Handle refresh tokens" --parent 3 --project ~/Code/provider-service

# Lifecycle (triggers tmux/Claude actions)
laundry open 3                      # pending/paused → active
laundry pause 3                     # active → paused
laundry done 3                      # active → completed
laundry cancel 3                    # → cancelled

# Update metadata (no state change)
laundry update 3 --title "New title"
laundry update 3 --description "More detail"
laundry link 3 --pr org/repo#42
laundry link 3 --jira PROJ-123
laundry unlink 3 --pr org/repo#42

# Notes
laundry note 3 "Found root cause"   # appends timestamped line to notes md
laundry note 3 --edit                # opens notes file in $EDITOR

# Query
laundry list                         # pending + active (default)
laundry list --all                   # everything including completed/cancelled
laundry list --status active
laundry list --parent 3              # subtasks of task 3
laundry list --format tv             # television source format
laundry show 3                       # full detail (for tv preview)
```

### Atomic writes

All mutations go through a single `_save()` function: write to `tasks.json.tmp`, then `os.rename()` to `tasks.json`. No partial writes.

### Slug generation

Notes files use `<id>-<slugified-title>.md`. The slug is generated once at task creation (lowercase, hyphens, truncated to 50 chars). Stored in `notes_file` — title renames don't affect the filename.

## tmux Integration

### `laundry open <id>`

If task is already `active` and `tmux_window_id` exists and is valid: just switch to it (`tmux switch-client -t <window_id>`). No state change.

If task is `pending`:
1. Determine tmux session from project path. Convention: session name = basename of project dir (matching existing sesh behavior). If session doesn't exist, create it via `tmux new-session -d -s <name> -c <project>`.
2. Create a new window in that session: `tmux new-window -t <session> -c <project> -n "L<id>"`
3. Capture the new window's `@id` via `tmux display-message -p '#{window_id}'`
4. Store `tmux_window_id` in the task
5. Build the initial Claude prompt, write to a temp file `/tmp/laundry-prompt-<id>.txt`
6. Send `claude -n "L<id>" "$(cat /tmp/laundry-prompt-<id>.txt)" && rm /tmp/laundry-prompt-<id>.txt` to the window via `tmux send-keys`. The `-n` flag sets the session name for later resume.
7. Switch to the window
8. Status → `active`

If task is `paused`: same as above but step 6 uses `claude --resume <session_id>` instead of a fresh instance with initial prompt.

### `laundry pause <id>`

1. Read `tmux_window_id` from task
2. Capture `claude_session_id` if not already stored (parse from Claude's transcript path in `~/.claude/projects/`)
3. Kill the tmux window: `tmux kill-window -t <window_id>`
4. Clear `tmux_window_id` from task
5. Status → `paused`

### `laundry done <id>` / `laundry cancel <id>`

1. Kill tmux window if it exists
2. Clear `tmux_window_id` and `claude_session_id`
3. Status → `completed` / `cancelled`

### Window naming

The tmux window name is set to `L<id>: <title>` (e.g., `L3: fix-auth-expiry`). The existing claude-name-watcher hook may override this — that's fine, it reflects what Claude is actually doing.

## Claude Integration

### Initial prompt

When `laundry open` spawns Claude, it sends this as the initial prompt via `tmux send-keys`:

```
You are working on laundry task #<id>: "<title>"

<description>

<contents of notes file if it exists>

Manage this task with the `laundry` CLI:
- `laundry note <id> "..."` — log progress to notes file
- `laundry link <id> --pr owner/repo#N` — link a PR
- `laundry link <id> --jira PROJ-N` — link a Jira ticket
- `laundry add "subtask title" --parent <id>` — break work into subtasks
- `laundry done <id>` — mark complete when finished
```

The prompt is built by the Python CLI and properly escaped for tmux send-keys.

### Subtask creation

When Claude runs `laundry add "subtask" --parent 3`, the new task is added with `parent_id: 3` and status `pending`. It appears in the task list immediately. The user (or Claude) can `laundry open` it later, which spawns a separate tmux window + Claude instance.

### Session ID capture

A `SessionStart` hook captures the Claude session ID:
1. Hook reads `TMUX_PANE` env var to get the current pane ID
2. Derives the window ID from the pane: `tmux display-message -t $TMUX_PANE -p '#{window_id}'`
3. Looks up the task by matching `tmux_window_id` in `tasks.json`
4. If found, writes the session ID back: `laundry update <id> --claude-session <session_id>`

The session ID is available in the hook's stdin JSON payload (`session_id` field).

## Television Channel

### `~/.config/television/cable/laundry.toml`

```toml
[metadata]
name = "laundry"
description = "Task list — jump to Claude workspaces"

[source]
command = "laundry list --format tv"
no_sort = true

[preview]
command = "laundry show {0}"

[keybindings]
enter = "confirm_selection"
ctrl-x = "toggle_action_picker"

[actions.open]
description = "Open / jump to task"
command = "laundry open {0}"
mode = "fork"

[actions.pause]
description = "Pause task"
command = "laundry pause {0}"
mode = "fork"

[actions.done]
description = "Mark complete"
command = "laundry done {0}"
mode = "fork"

[actions.cancel]
description = "Cancel task"
command = "laundry cancel {0}"
mode = "fork"
```

### `--format tv` output

One line per task, tab-separated: `<id>\t<status_icon>\t<title>\t<project_basename>\t<jira_refs>`.

Status icons: `○` pending, `▶` active, `⏸` paused, `✓` completed, `✗` cancelled.

Example:
```
3	▶	Fix auth token expiry	provider-service	PROJ-123
4	○	Handle refresh tokens	provider-service
7	⏸	Update billing docs	dotfiles
```

### tmux keybinding

```bash
# In keybind.conf — replaces current prefix+f (claude-picker)
bind f display-popup -E -w 80% -h 80% "tv laundry"
```

The current claude-picker (`prefix+f`) is replaced. If you still want pane-level Claude discovery, it can move to a different binding.

### Jump behavior

When selecting a task with `enter`:
- If `active`: `tmux switch-client -t <window_id>` — jump directly to the window
- If `pending`/`paused`: `laundry open <id>` — spawn window then jump
- If `completed`/`cancelled`: show in preview only (no action on enter, or optionally open notes)

## File Placement

```
~/.dotfiles/
├── laundry/
│   ├── laundry.py                  # the CLI (symlinked to PATH)
│   └── laundry-session-hook.sh     # SessionStart hook for capturing session ID
├── claude/hooks.d/SessionStart/
│   └── laundry-session.sh          # symlink to above
└── install.conf.yaml               # updated: symlink laundry.py, hook, tv channel
```

The `laundry` command is symlinked to somewhere on PATH (e.g., `~/.local/bin/laundry`) via dotbot.

## Future Extensions (not in scope now)

- **TUI mode**: `laundry tui` — full terminal UI with live task board, inline notes editing, tmux pane previews
- **Auto-complete on done**: when all subtasks of a parent complete, prompt to complete the parent
- **Priority/ordering**: drag tasks up/down in the picker
- **Time tracking**: record active time per task via tmux hooks
- **Template tasks**: recurring task patterns (e.g., "on-call rotation" template)
