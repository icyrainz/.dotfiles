# Laundry

Task-driven Claude workspace manager built on tmux.

Each task gets its own tmux window with a dedicated Claude Code session. Tasks can be paused (window killed, session preserved) and resumed later. A background daemon watches for orphaned windows and syncs tmux window names to task metadata.

## Prerequisites

- **tmux** — the process manager; owns window lifecycle, multiplexing, and detach/reattach
- **Python 3** — the `laundry` CLI and daemon
- **Claude Code** — launched per-task via `claude --session-id`

## tmux keybindings

All bindings use the tmux prefix (`C-Space` in this setup):

| Key | Action |
|-----|--------|
| `prefix f` | Open the task TV — browse and switch between tasks |
| `prefix a` | Attach current tmux window to laundry (reattaches if an existing task is detected, otherwise creates a new one) |
| `prefix A` | Quick-add a new task — prompts for description and project directory, then opens it |

## CLI

```
laundry add "title" [-p dir]   Create a task
laundry open <id>              Open task (creates tmux window + Claude)
laundry pause <id>             Pause task (kills window, keeps session)
laundry done <id>              Mark complete
laundry cancel <id>            Cancel task
laundry reopen <id>            Reopen completed/cancelled task
laundry delete <id>            Delete task permanently

laundry attach                 Attach current tmux window as a task
laundry list [-a] [-f tv]      List tasks (--all includes done/cancelled)
laundry show <id>              Show task detail + notes
laundry update <id> --title .. Update metadata
laundry link <id> --pr o/r#N   Link a PR or Jira ticket
laundry unlink <id> --pr ..    Remove a link

laundry status                 Task counts + daemon health
laundry gc                     Manually reconcile orphaned tasks
laundry serve                  Start the daemon (usually via shell init)
laundry reset                  Wipe all tasks
```

## Task lifecycle

```
pending ──> active ──> paused ──> active (reopen)
              │          │
              ├──> completed
              └──> cancelled ──> pending (reopen)
```

- **pending** — created but not yet opened
- **active** — has a live tmux window with Claude
- **paused** — window killed, Claude session preserved on disk
- **completed/cancelled** — terminal states, can be reopened

## Daemon

`laundry serve` starts a background daemon that:

- Polls tmux every 2s to detect orphaned windows (auto-pauses tasks whose windows disappeared)
- Syncs tmux window names to task titles (the name watcher sets the window name from Claude's session slug, the daemon reads it back into task metadata)

## Harpoon integration

Tasks can be pinned to slots 1-4 for instant switching:

| Key | Action |
|-----|--------|
| `Alt+1..4` | Jump to pinned slot |
| `prefix Alt+1..4` | Pin current window to slot |

Pinned slots show in the TV task list.

## Data

- Task state: `~/.local/share/laundry/tasks.json`
- Notes: `~/.local/share/laundry/notes/<task-id>-<slug>.md`
- Daemon socket: `~/.local/share/laundry/laundry.sock`
