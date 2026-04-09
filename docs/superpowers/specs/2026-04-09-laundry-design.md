# Laundry: Task-Driven Claude Workspace Manager

## Summary

A CLI tool (`laundry`) that manages a task list where each task has an associated Claude Code instance running inside a tmux window. Tasks are the unit of work — they can be vague ideas or specific subtasks. Claude instances self-manage their task state via the `laundry` CLI. A television channel provides a fuzzy picker (`prefix+f`) to browse and jump across tasks.

## Mental Model

Current: tmux sessions are per-repo, Claude instances are discovered by scanning panes.

New: a **task list** is the primary interface. Each task maps to a tmux window (inside the session for its repo). `prefix+f` shows tasks, not panes. Jumping to a task lands you in the tmux window where Claude is working on it.

Tasks start vague, get refined through conversation with Claude, and can be broken down into subtasks that feed back into the same list.

Non-laundry Claude instances still work via `prefix+c` — laundry is an opt-in layer, not a replacement for ad-hoc Claude sessions.

## Data Model

### Storage layout

```
~/.local/share/laundry/
├── tasks.json                                          # structured index, sole source of truth
├── tasks.json.lock                                     # flock lockfile for concurrent access
└── notes/
    ├── 20260409-143000-fix-auth-token-expiry.md        # freeform task log (mini PROGRESS.md)
    └── 20260409-144500-handle-refresh-tokens.md
```

### Task schema (`tasks.json`)

```json
{
  "version": 1,
  "tasks": [
    {
      "id": "20260409-143000",
      "title": "Fix auth token expiry in provider-service",
      "description": "Refresh tokens aren't being rotated when the upstream provider returns a 401.",
      "status": "active",
      "parent_id": null,
      "project": "/Users/tue.phan/Code/provider-service",
      "initial_prompt": "the token expiry is broken, look into it",
      "tmux_window_id": "@42",
      "claude_session_id": "abc-123-def",
      "launched": true,
      "links": {
        "prs": ["org/repo#42", "org/repo#45"],
        "jira": ["PROJ-123"]
      },
      "notes_file": "20260409-143000-fix-auth-token-expiry.md",
      "created_at": "2026-04-09T14:30:00Z",
      "updated_at": "2026-04-09T14:30:00Z"
    }
  ]
}
```

Key design decisions:
- **ID is a datetime slug** (`YYYYMMDD-HHMMSS`) — no auto-increment counter to track. On collision (two tasks in same second), retry with incremented second.
- **title and description** are initially empty or auto-generated. The Claude instance managing the task updates them as it understands the work better.
- **initial_prompt** stores the user's original task idea (provided during interactive creation). Used as the first user message when spawning Claude.
- **launched** tracks whether Claude has been started for this task. `false` → use `--session-id` (fresh). `true` → use `--resume` (returning).
- **links** contain only PRs and Jira tickets (structured, queryable). All other context goes in the notes file.

Non-project tasks default to `~/.dotfiles` as project and land in the `dotfiles` tmux session.

### Notes file

Freeform markdown per task. Claude reads and writes this directly (like PROGRESS.md) — no CLI command needed. The system prompt tells Claude the notes file path. Also serves as the tv preview content.

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

### State-to-field mapping

| State     | tmux_window_id | claude_session_id |
|-----------|----------------|-------------------|
| pending   | null           | null              |
| active    | @42            | abc-123           |
| paused    | null           | abc-123 (preserved for resume) |
| completed | null           | abc-123 (preserved for reopen) |
| cancelled | null           | abc-123 (preserved for reopen) |

### State transitions

```
pending     → active       laundry open <id>     creates window + launches Claude
pending     → cancelled    laundry cancel <id>

active      → paused       laundry pause <id>    kills window, saves session ID
active      → completed    laundry done <id>     kills window
active      → cancelled    laundry cancel <id>   kills window

paused      → active       laundry open <id>     creates window + claude --resume
paused      → cancelled    laundry cancel <id>

completed   → pending      laundry reopen <id>   preserves session ID + notes for resume
cancelled   → pending      laundry reopen <id>   preserves session ID + notes for resume
```

## CLI Interface

Single Python file, no pip dependencies (stdlib only: `json`, `argparse`, `subprocess`, `pathlib`, `datetime`, `fcntl`, `uuid`).

```bash
# Create (programmatic — used by Claude for subtasks)
laundry add "Handle refresh tokens" --parent 20260409-143000 --project ~/Code/provider-service

# Lifecycle (triggers tmux/Claude actions)
laundry open 20260409-143000          # pending/paused → active (or jump if already active)
laundry pause 20260409-143000         # active → paused
laundry done 20260409-143000          # active → completed
laundry cancel 20260409-143000        # → cancelled
laundry reopen 20260409-143000        # completed/cancelled → pending

# Update metadata (no state change — used by Claude to refine task info)
laundry update 20260409-143000 --title "New title"
laundry update 20260409-143000 --description "More detail"
laundry update 20260409-143000 --claude-session abc-123-def
laundry link 20260409-143000 --pr org/repo#42
laundry link 20260409-143000 --jira PROJ-123
laundry unlink 20260409-143000 --pr org/repo#42

# Maintenance
laundry gc                            # reconcile with tmux: mark orphaned active tasks as paused

# Query
laundry list                          # pending + active (default)
laundry list --all                    # everything including completed/cancelled
laundry list --status active
laundry list --parent 20260409-143000 # subtasks of a task
laundry list --format tv              # television source format
laundry show 20260409-143000          # full detail (for tv preview)
```

### Concurrency: flock-based locking

All mutations acquire an exclusive lock on `tasks.json.lock` via `fcntl.flock()` before reading, modifying, and writing. This prevents data loss when multiple writers (user CLI, Claude instances, hooks) run concurrently.

```python
with open(LOCK_FILE, 'w') as lock:
    fcntl.flock(lock, fcntl.LOCK_EX)
    data = _load()
    # ... modify data ...
    _save(data)  # write to .tmp then os.rename()
```

### Atomic writes

All mutations go through a single `_save()` function: write to `tasks.json.tmp`, then `os.rename()` to `tasks.json`. No partial writes. Always inside the flock.

### ID generation

Generate `YYYYMMDD-HHMMSS` from current time. If an existing task has the same ID, increment the second and retry (handles sub-second programmatic creation like Claude adding multiple subtasks).

### Slug generation

Notes files use `<id>-<slugified-title>.md`. The slug is generated once at task creation (lowercase, hyphens, truncated to 50 chars). Stored in `notes_file` — title renames don't affect the filename. If title is empty at creation, the slug is derived from the first few words of `initial_prompt`.

## Task Creation Flow

### Interactive creation (`prefix+F`)

`prefix+F` (capital F) opens an interactive quick-add flow in a tmux popup:

1. **Prompt for initial task idea** — freeform text input (becomes the first Claude prompt)
2. **Prompt for working directory** — fzf/tv picker from common dirs (sourced from zoxide `z --list` or sesh config). Default: current project dir.
3. Task is created immediately with:
   - `id`: current datetime slug
   - `initial_prompt`: the user's text from step 1
   - `title`: empty (Claude will set this)
   - `project`: selected directory
   - `status`: pending
4. `laundry open <id>` is called automatically — spawns tmux window + Claude

This is implemented as a small bash script (`laundry-new.sh`) that the tmux keybinding calls.

### Programmatic creation (by Claude)

Claude instances create subtasks via `laundry add "subtask title" --parent <id>`. These are added as `pending` and appear in the task list immediately.

## tmux Integration

### `laundry open <id>`

If task is already `active` and `tmux_window_id` is valid: just switch to it (`tmux switch-client -t <window_id>`). No state change.

If task is `pending` or `paused`:
1. Generate a `claude_session_id` (UUID4) if not already set, and write it to the task JSON
2. Set `status: active` in JSON
3. Determine tmux session from project path. Convention: session name = basename of project dir (matching existing sesh behavior). If session doesn't exist, create it via `tmux new-session -d -s <name> -c <project>`.
4. Create a new window via `tmux new-window -t <session> -c <project> -n "L<id>" "laundry launch <id>"` — the `laundry launch` subcommand handles Claude invocation directly in Python (no `tmux send-keys`, no escaping issues)
5. Capture the new window's `@id` via `tmux display-message -p '#{window_id}'` and update the task
6. Switch to the window

### `laundry launch <id>` (internal subcommand)

Executed as the tmux window command — runs inside the window, not via send-keys. This avoids all escaping issues since Python handles argument construction directly.

1. Read task from JSON (has `claude_session_id` already set by `laundry open`)
2. Build the system prompt string (see Claude Integration below)
3. If fresh task (no prior conversation): `os.execvp("claude", ["claude", "--session-id", session_id, "--append-system-prompt", system_prompt, "-n", f"L{task_id}", initial_prompt])`
4. If resuming (has prior conversation): `os.execvp("claude", ["claude", "--resume", session_id, "--append-system-prompt", system_prompt])`

The `--session-id` flag lets us control the UUID — we generate it in Python and persist it in the task JSON before Claude starts. No hooks needed to capture it.

Uses `os.execvp` to replace the Python process with Claude — clean process tree, no wrapper overhead.

### `laundry pause <id>`

1. Read `tmux_window_id` from task
2. Kill the tmux window: `tmux kill-window -t <window_id>`
4. Clear `tmux_window_id` from task
5. Status → `paused`

### `laundry done <id>` / `laundry cancel <id>`

1. Kill tmux window if it exists
2. Clear `tmux_window_id` (preserve `claude_session_id` for potential reopen)
3. Status → `completed` / `cancelled`

### `laundry reopen <id>`

1. Status → `pending` (preserves `claude_session_id` and `notes_file`)
2. Optionally auto-call `laundry open <id>` to immediately activate

### `laundry gc` (garbage collection / reconciliation)

Reconciles task state with tmux reality. Run on tmux server startup or manually.

1. For each task with status `active`:
   - Check if `tmux_window_id` still exists: `tmux list-windows -a -F '#{window_id}'`
   - If window is gone: transition to `paused` (clear `tmux_window_id`, preserve `claude_session_id`)
2. Report what changed

Can be wired to tmux `session-created` hook or run at shell startup.

### Window naming

The tmux window name is set to `L<id>` initially. The existing claude-name-watcher hook may override this as Claude works — that's fine, it reflects what Claude is actually doing.

## Claude Integration

### System prompt (via `--append-system-prompt`)

When `laundry launch` spawns Claude, it passes context via `--append-system-prompt "$(cat ...)"`:

```
You are working on laundry task #<id>.
Notes file: ~/.local/share/laundry/notes/<notes_file>
Read and update the notes file directly to track your progress.

Manage this task with the `laundry` CLI:
- `laundry update <id> --title "..."` — set/update task title
- `laundry update <id> --description "..."` — set/update task description
- `laundry link <id> --pr owner/repo#N` — link a PR
- `laundry link <id> --jira PROJ-N` — link a Jira ticket
- `laundry add "subtask title" --parent <id>` — break work into subtasks
- `laundry done <id>` — mark complete when finished
```

This is always passed — both for fresh launches and resumes. On resume, conversation history provides the working context; the system prompt provides the laundry CLI reference (which is not preserved across resumes).

### Subtask creation

When Claude runs `laundry add "subtask" --parent <id>`, the new task is added with `parent_id` and status `pending`. It appears in the task list immediately. The user (or Claude) can `laundry open` it later, which spawns a separate tmux window + Claude instance.

### Session ID management

The `claude_session_id` is a UUID4 generated by `laundry open` and stored in the task JSON *before* Claude launches. It is passed to Claude via `--session-id <uuid>` (fresh) or `--resume <uuid>` (resume). No hooks are needed — laundry owns the session ID end-to-end.

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
20260409-143000	▶	Fix auth token expiry	provider-service	PROJ-123
20260409-144500	○	Handle refresh tokens	provider-service
20260409-150000	⏸	Update billing docs	dotfiles
```

### tmux keybindings

```bash
# In keybind.conf
bind f display-popup -E -w 80% -h 80% "tv laundry"           # browse/jump to tasks
bind F display-popup -E -w 60% -h 40% "laundry-new.sh"       # quick-add new task
# prefix+c remains unchanged — spawns ad-hoc (non-laundry) Claude windows
```

`prefix+f` replaces the current claude-picker. `prefix+F` opens the interactive new-task flow. `prefix+c` continues to work for ad-hoc Claude sessions outside laundry.

### Jump behavior

When selecting a task with `enter`:
- If `active`: `tmux switch-client -t <window_id>` — jump directly to the window
- If `pending`/`paused`: `laundry open <id>` — spawn window then jump
- If `completed`/`cancelled`: show in preview only (no action on enter, or optionally open notes)

## File Placement

```
~/.dotfiles/
├── laundry/
│   ├── laundry.py                  # the CLI (symlinked to ~/.local/bin/laundry)
│   └── laundry-new.sh              # interactive quick-add script (for prefix+F)
└── install.conf.yaml               # updated: symlink laundry.py, tv channel
```

The `laundry` command is symlinked to `~/.local/bin/laundry` via dotbot.

## Future Extensions (not in scope now)

- **TUI mode**: `laundry tui` — full terminal UI with live task board, inline notes editing, tmux pane previews
- **Auto-complete on done**: when all subtasks of a parent complete, prompt to complete the parent
- **Priority/ordering**: drag tasks up/down in the picker
- **Time tracking**: record active time per task via tmux hooks
- **Template tasks**: recurring task patterns (e.g., "on-call rotation" template)
