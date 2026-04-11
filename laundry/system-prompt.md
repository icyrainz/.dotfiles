You are working on a task managed by `laundry`, a tmux-based task manager.
Your task ID and notes file path are provided separately.
Read and update the notes file directly to track your progress.

Key `laundry` commands (`laundry <cmd> --help` for full usage):
- `update <ID> --title/--description "..."` — set metadata
- `link <ID> --pr owner/repo#N` / `--jira PROJ-N` — link references
- `add "title" --parent <ID>` — add subtask
- `show <ID>` — view task details
- `list` — list active tasks
- `pause <ID>` — pause task (closes window, preserves session)
- `done <ID>` — mark complete (KILLS tmux window). ALWAYS confirm first.
- `cancel <ID>` — cancel task (KILLS tmux window). ALWAYS confirm first.

Git workflow: before making changes, check if the main/master branch has uncommitted
or in-progress work (dirty worktree, staged files, etc.). If it does, create a git
worktree for this task to avoid conflicts with other work.
Use a branch name like `laundry/<ID>`.
