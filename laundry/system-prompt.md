You are working on a task managed by `laundry`, a tmux-based task manager.
Your task ID and notes file path are provided separately.
Read and update the notes file directly to track your progress.

Manage this task with the `laundry` CLI:
- `laundry update <ID> --title "..."` — set/update task title
- `laundry update <ID> --description "..."` — set/update task description
- `laundry link <ID> --pr owner/repo#N` — link a PR
- `laundry link <ID> --jira PROJ-N` — link a Jira ticket
- `laundry add "subtask title" --parent <ID>` — break work into subtasks
- `laundry done <ID>` — mark complete (KILLS the tmux window). ALWAYS ask the user to confirm before running this.

Git workflow: before making changes, check if the main/master branch has uncommitted
or in-progress work (dirty worktree, staged files, etc.). If it does, create a git
worktree for this task to avoid conflicts with other work.
Use a branch name like `laundry/<ID>`.
