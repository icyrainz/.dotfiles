#!/usr/bin/env python3
"""Laundry — task-driven Claude workspace manager."""

import json
import os
import sys
import fcntl
import uuid
import re
import subprocess
from pathlib import Path
from datetime import datetime, timezone, timedelta

DATA_DIR = Path.home() / ".local" / "share" / "laundry"
TASKS_FILE = DATA_DIR / "tasks.json"
LOCK_FILE = DATA_DIR / "tasks.json.lock"
NOTES_DIR = DATA_DIR / "notes"

VALID_STATUSES = ("pending", "active", "paused", "completed", "cancelled")

TRANSITIONS = {
    ("pending", "active"),
    ("pending", "cancelled"),
    ("active", "paused"),
    ("active", "completed"),
    ("active", "cancelled"),
    ("paused", "active"),
    ("paused", "cancelled"),
    ("completed", "pending"),
    ("cancelled", "pending"),
}

STATUS_ICONS = {
    "pending": "○",
    "active": "▶",
    "paused": "⏸",
    "completed": "◉",
    "cancelled": "◌",
}


def _ensure_dirs():
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    NOTES_DIR.mkdir(parents=True, exist_ok=True)


def _load():
    if not TASKS_FILE.exists():
        return {"version": 1, "tasks": []}
    with open(TASKS_FILE) as f:
        return json.load(f)


def _save(data):
    tmp = TASKS_FILE.with_suffix(".json.tmp")
    with open(tmp, "w") as f:
        json.dump(data, f, indent=2)
        f.write("\n")
    os.rename(tmp, TASKS_FILE)


def _now_iso():
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def _generate_id(data):
    now = datetime.now()
    existing_ids = {t["id"] for t in data["tasks"]}
    for offset in range(60):
        candidate = now + timedelta(seconds=offset)
        slug = candidate.strftime("%Y%m%d-%H%M%S")
        if slug not in existing_ids:
            return slug
    raise RuntimeError("Could not generate unique task ID")


def _slugify(text, max_len=50):
    text = text.lower().strip()
    text = re.sub(r"[^a-z0-9\s-]", "", text)
    text = re.sub(r"[\s_]+", "-", text)
    text = re.sub(r"-+", "-", text).strip("-")
    return text[:max_len]


def _find_task(data, task_id):
    for task in data["tasks"]:
        if task["id"] == task_id:
            return task
    return None


# --- tmux helpers ---


def _tmux_window_exists(window_id):
    if not window_id:
        return False
    try:
        result = subprocess.run(
            ["tmux", "list-windows", "-a", "-F", "#{window_id}"],
            capture_output=True, text=True,
        )
        return window_id in result.stdout.splitlines()
    except FileNotFoundError:
        return False


def _tmux_switch(window_id):
    subprocess.run(["tmux", "switch-client", "-t", window_id])


def _tmux_session_exists(session_name):
    result = subprocess.run(
        ["tmux", "has-session", "-t", session_name],
        capture_output=True,
    )
    return result.returncode == 0


def _kill_task_window(task):
    wid = task.get("tmux_window_id")
    if wid and _tmux_window_exists(wid):
        subprocess.run(["tmux", "kill-window", "-t", wid], capture_output=True)


def _build_system_prompt(task):
    tid = task["id"]
    notes_path = NOTES_DIR / task["notes_file"]
    return f"""You are working on laundry task #{tid}.
Notes file: {notes_path}
Read and update the notes file directly to track your progress.

Manage this task with the `laundry` CLI:
- `laundry update {tid} --title "..."` — set/update task title
- `laundry update {tid} --description "..."` — set/update task description
- `laundry link {tid} --pr owner/repo#N` — link a PR
- `laundry link {tid} --jira PROJ-N` — link a Jira ticket
- `laundry add "subtask title" --parent {tid}` — break work into subtasks
- `laundry done {tid}` — mark complete when finished"""


# --- commands ---


def cmd_add(args):
    _ensure_dirs()
    with open(LOCK_FILE, "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        data = _load()

        task_id = _generate_id(data)
        title = args.title or ""
        project = (
            str(Path(args.project).expanduser().resolve())
            if args.project
            else str(Path.home() / "Github" / ".dotfiles")
        )
        slug_source = title if title else (args.prompt or "task")
        notes_filename = f"{task_id}-{_slugify(slug_source)}.md"

        task = {
            "id": task_id,
            "title": title,
            "description": "",
            "status": "pending",
            "parent_id": args.parent,
            "project": project,
            "initial_prompt": args.prompt or title,
            "tmux_window_id": None,
            "claude_session_id": None,
            "launched": False,
            "links": {"prs": [], "jira": []},
            "notes_file": notes_filename,
            "created_at": _now_iso(),
            "updated_at": _now_iso(),
        }

        data["tasks"].append(task)
        _save(data)

    notes_path = NOTES_DIR / notes_filename
    if not notes_path.exists():
        notes_path.write_text(f"# {title or 'New task'}\n")

    print(task_id)
    return task_id


def cmd_list(args):
    _ensure_dirs()
    data = _load()
    tasks = data["tasks"]

    if args.status:
        tasks = [t for t in tasks if t["status"] == args.status]
    elif not args.all:
        tasks = [t for t in tasks if t["status"] in ("pending", "active", "paused")]

    if args.parent:
        tasks = [t for t in tasks if t.get("parent_id") == args.parent]

    if args.format == "tv":
        # For tv: also include today's completed/cancelled (dimmed at bottom)
        today = datetime.now().strftime("%Y%m%d")
        if not args.all and not args.status:
            done_today = [
                t for t in data["tasks"]
                if t["status"] in ("completed", "cancelled")
                and t.get("updated_at", "")[:10].replace("-", "").startswith(today)
            ]
            tasks = tasks + done_today

        if not tasks:
            print("-\t \tNo tasks yet — press prefix+A to add one\t\t")
            return

        for t in tasks:
            icon = STATUS_ICONS.get(t["status"], "?")
            title = t["title"] or t.get("initial_prompt", "")[:60] or "(untitled)"
            project = Path(t["project"]).name if t["project"] else ""
            jira = " ".join(t.get("links", {}).get("jira", []))
            print(f"{t['id']}\t{icon}\t{title}\t{project}\t{jira}")
    else:
        for t in tasks:
            icon = STATUS_ICONS.get(t["status"], "?")
            title = t["title"] or t.get("initial_prompt", "")[:60] or "(untitled)"
            parent_str = f"  ↳ child of {t['parent_id']}" if t.get("parent_id") else ""
            print(f"  {icon} {t['id']}  {title}{parent_str}")


def cmd_show(args):
    _ensure_dirs()
    data = _load()
    task = _find_task(data, args.id)
    if not task:
        print(f"Task {args.id} not found", file=sys.stderr)
        sys.exit(1)

    icon = STATUS_ICONS.get(task["status"], "?")
    title = task["title"] or "(untitled)"
    print(f"{icon} {task['id']}: {title}")
    print(f"  Status:  {task['status']}")
    print(f"  Project: {task['project']}")
    if task.get("parent_id"):
        print(f"  Parent:  {task['parent_id']}")
    if task.get("description"):
        print(f"  Description: {task['description']}")
    if task.get("initial_prompt"):
        print(f"  Prompt:  {task['initial_prompt']}")
    prs = task.get("links", {}).get("prs", [])
    jira = task.get("links", {}).get("jira", [])
    if prs:
        print(f"  PRs:     {', '.join(prs)}")
    if jira:
        print(f"  Jira:    {', '.join(jira)}")
    if task.get("claude_session_id"):
        print(f"  Session: {task['claude_session_id']}")
    if task.get("tmux_window_id"):
        print(f"  Window:  {task['tmux_window_id']}")
    print(f"  Created: {task['created_at']}")
    print(f"  Updated: {task['updated_at']}")

    notes_path = NOTES_DIR / task["notes_file"]
    if notes_path.exists():
        content = notes_path.read_text().strip()
        if content:
            print(f"\n--- Notes ---\n{content}")


def cmd_update(args):
    _ensure_dirs()
    with open(LOCK_FILE, "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        data = _load()
        task = _find_task(data, args.id)
        if not task:
            print(f"Task {args.id} not found", file=sys.stderr)
            sys.exit(1)

        if args.title is not None:
            task["title"] = args.title
        if args.description is not None:
            task["description"] = args.description
        if args.claude_session is not None:
            task["claude_session_id"] = args.claude_session
        task["updated_at"] = _now_iso()
        _save(data)
    print(f"Updated {args.id}")


def cmd_link(args):
    _ensure_dirs()
    with open(LOCK_FILE, "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        data = _load()
        task = _find_task(data, args.id)
        if not task:
            print(f"Task {args.id} not found", file=sys.stderr)
            sys.exit(1)

        if args.pr and args.pr not in task["links"]["prs"]:
            task["links"]["prs"].append(args.pr)
        if args.jira and args.jira not in task["links"]["jira"]:
            task["links"]["jira"].append(args.jira)
        task["updated_at"] = _now_iso()
        _save(data)
    print(f"Linked {args.id}")


def cmd_unlink(args):
    _ensure_dirs()
    with open(LOCK_FILE, "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        data = _load()
        task = _find_task(data, args.id)
        if not task:
            print(f"Task {args.id} not found", file=sys.stderr)
            sys.exit(1)

        if args.pr and args.pr in task["links"]["prs"]:
            task["links"]["prs"].remove(args.pr)
        if args.jira and args.jira in task["links"]["jira"]:
            task["links"]["jira"].remove(args.jira)
        task["updated_at"] = _now_iso()
        _save(data)
    print(f"Unlinked {args.id}")


def cmd_open(args):
    _ensure_dirs()
    with open(LOCK_FILE, "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        data = _load()
        task = _find_task(data, args.id)
        if not task:
            print(f"Task {args.id} not found", file=sys.stderr)
            sys.exit(1)

        # If already active with valid window, just switch
        if task["status"] == "active" and _tmux_window_exists(task.get("tmux_window_id")):
            _tmux_switch(task["tmux_window_id"])
            return

        if task["status"] not in ("pending", "paused"):
            print(f"Cannot open task in '{task['status']}' state (must be pending or paused)", file=sys.stderr)
            sys.exit(1)

        if not task.get("claude_session_id"):
            task["claude_session_id"] = str(uuid.uuid4())

        # Determine tmux session
        project_path = Path(task["project"])
        session_name = project_path.name.replace(".", "_")  # tmux maps dots to underscores
        if not _tmux_session_exists(session_name):
            subprocess.run(
                ["tmux", "new-session", "-d", "-s", session_name, "-c", str(project_path)],
                capture_output=True,
            )

        # Create window with laundry launch as the command
        laundry_bin = Path(__file__).resolve()
        result = subprocess.run(
            [
                "tmux", "new-window", "-t", session_name, "-c", str(project_path),
                "-n", f"L{task['id']}", "-P", "-F", "#{window_id}",
                "python3", str(laundry_bin), "launch", task["id"],
            ],
            capture_output=True, text=True,
        )
        window_id = result.stdout.strip()
        task["tmux_window_id"] = window_id
        task["status"] = "active"
        task["updated_at"] = _now_iso()
        _save(data)

    _tmux_switch(window_id)


def cmd_launch(args):
    """Internal: executed as tmux window command. Replaces itself with claude via execvp."""
    _ensure_dirs()

    data = _load()
    task = _find_task(data, args.id)
    if not task:
        print(f"Task {args.id} not found", file=sys.stderr)
        sys.exit(1)

    system_prompt = _build_system_prompt(task)
    session_id = task["claude_session_id"]
    is_resume = task.get("launched", False)

    # Mark as launched for next time
    with open(LOCK_FILE, "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        data = _load()
        t = _find_task(data, args.id)
        t["launched"] = True
        _save(data)

    if is_resume:
        os.execvp("claude", [
            "claude",
            "--resume", session_id,
            "--append-system-prompt", system_prompt,
        ])
    else:
        cmd = [
            "claude",
            "--session-id", session_id,
            "--append-system-prompt", system_prompt,
            "-n", f"L{task['id']}",
        ]
        if task.get("initial_prompt"):
            cmd.append(task["initial_prompt"])
        os.execvp("claude", cmd)


def cmd_pause(args):
    _ensure_dirs()
    with open(LOCK_FILE, "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        data = _load()
        task = _find_task(data, args.id)
        if not task:
            print(f"Task {args.id} not found", file=sys.stderr)
            sys.exit(1)
        if task["status"] != "active":
            print(f"Cannot pause task in '{task['status']}' state", file=sys.stderr)
            sys.exit(1)

        _kill_task_window(task)
        task["tmux_window_id"] = None
        task["status"] = "paused"
        task["updated_at"] = _now_iso()
        _save(data)
    print(f"Paused {args.id}")


def cmd_done(args):
    _ensure_dirs()
    with open(LOCK_FILE, "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        data = _load()
        task = _find_task(data, args.id)
        if not task:
            print(f"Task {args.id} not found", file=sys.stderr)
            sys.exit(1)
        if task["status"] != "active":
            print(f"Cannot complete task in '{task['status']}' state", file=sys.stderr)
            sys.exit(1)

        _kill_task_window(task)
        task["tmux_window_id"] = None
        task["status"] = "completed"
        task["updated_at"] = _now_iso()
        _save(data)
    print(f"Completed {args.id}")


def cmd_cancel(args):
    _ensure_dirs()
    with open(LOCK_FILE, "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        data = _load()
        task = _find_task(data, args.id)
        if not task:
            print(f"Task {args.id} not found", file=sys.stderr)
            sys.exit(1)
        if task["status"] in ("completed", "cancelled"):
            print(f"Task already {task['status']}", file=sys.stderr)
            sys.exit(1)

        _kill_task_window(task)
        task["tmux_window_id"] = None
        task["status"] = "cancelled"
        task["updated_at"] = _now_iso()
        _save(data)
    print(f"Cancelled {args.id}")


def cmd_reopen(args):
    _ensure_dirs()
    with open(LOCK_FILE, "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        data = _load()
        task = _find_task(data, args.id)
        if not task:
            print(f"Task {args.id} not found", file=sys.stderr)
            sys.exit(1)
        if task["status"] not in ("completed", "cancelled"):
            print(f"Cannot reopen task in '{task['status']}' state", file=sys.stderr)
            sys.exit(1)

        task["status"] = "pending"
        task["tmux_window_id"] = None
        task["updated_at"] = _now_iso()
        _save(data)
    print(f"Reopened {args.id}")


def cmd_reset(args):
    import shutil
    _ensure_dirs()
    with open(LOCK_FILE, "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        data = _load()

        # Kill all active tmux windows
        for task in data["tasks"]:
            if task["status"] == "active":
                _kill_task_window(task)

        # Wipe everything
        _save({"version": 1, "tasks": []})

    # Remove all notes
    shutil.rmtree(NOTES_DIR, ignore_errors=True)
    NOTES_DIR.mkdir(parents=True, exist_ok=True)
    print("All tasks wiped")


def cmd_gc(args):
    _ensure_dirs()
    with open(LOCK_FILE, "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        data = _load()
        changed = []

        for task in data["tasks"]:
            if task["status"] == "active" and not _tmux_window_exists(task.get("tmux_window_id")):
                task["tmux_window_id"] = None
                task["status"] = "paused"
                task["updated_at"] = _now_iso()
                changed.append(task["id"])

        if changed:
            _save(data)
            for tid in changed:
                print(f"Paused orphaned task {tid}")
        else:
            print("No orphaned tasks found")


# --- main ---


def main():
    import argparse

    parser = argparse.ArgumentParser(prog="laundry", description="Task-driven Claude workspace manager")
    sub = parser.add_subparsers(dest="command")

    # add
    p_add = sub.add_parser("add", help="Create a new task")
    p_add.add_argument("title", nargs="?", default="", help="Task title")
    p_add.add_argument("--project", "-p", help="Project directory (default: ~/.dotfiles)")
    p_add.add_argument("--parent", help="Parent task ID for subtasks")
    p_add.add_argument("--prompt", help="Initial prompt for Claude (defaults to title)")

    # list
    p_list = sub.add_parser("list", help="List tasks")
    p_list.add_argument("--all", "-a", action="store_true", help="Show all statuses")
    p_list.add_argument("--status", "-s", choices=VALID_STATUSES, help="Filter by status")
    p_list.add_argument("--parent", help="Filter by parent task ID")
    p_list.add_argument("--format", "-f", choices=["tv"], help="Output format")

    # show
    p_show = sub.add_parser("show", help="Show task detail")
    p_show.add_argument("id", help="Task ID")

    # update
    p_update = sub.add_parser("update", help="Update task metadata")
    p_update.add_argument("id", help="Task ID")
    p_update.add_argument("--title", help="Set title")
    p_update.add_argument("--description", help="Set description")
    p_update.add_argument("--claude-session", help="Set Claude session ID")

    # link
    p_link = sub.add_parser("link", help="Link PR or Jira ticket")
    p_link.add_argument("id", help="Task ID")
    p_link.add_argument("--pr", help="PR reference (e.g., org/repo#42)")
    p_link.add_argument("--jira", help="Jira ticket (e.g., PROJ-123)")

    # unlink
    p_unlink = sub.add_parser("unlink", help="Remove PR or Jira link")
    p_unlink.add_argument("id", help="Task ID")
    p_unlink.add_argument("--pr", help="PR reference to remove")
    p_unlink.add_argument("--jira", help="Jira ticket to remove")

    # open
    p_open = sub.add_parser("open", help="Open/activate task (creates tmux window + Claude)")
    p_open.add_argument("id", help="Task ID")

    # launch (internal)
    p_launch = sub.add_parser("launch", help="Internal: launch Claude for a task")
    p_launch.add_argument("id", help="Task ID")

    # pause
    p_pause = sub.add_parser("pause", help="Pause task (kills tmux window, preserves session)")
    p_pause.add_argument("id", help="Task ID")

    # done
    p_done = sub.add_parser("done", help="Mark task complete")
    p_done.add_argument("id", help="Task ID")

    # cancel
    p_cancel = sub.add_parser("cancel", help="Cancel task")
    p_cancel.add_argument("id", help="Task ID")

    # reopen
    p_reopen = sub.add_parser("reopen", help="Reopen completed/cancelled task")
    p_reopen.add_argument("id", help="Task ID")

    # gc
    sub.add_parser("gc", help="Reconcile: pause tasks with missing tmux windows")

    # reset
    sub.add_parser("reset", help="Wipe all tasks and notes")

    args = parser.parse_args()
    if args.command is None:
        parser.print_help()
        sys.exit(1)

    commands = {
        "add": cmd_add,
        "list": cmd_list,
        "show": cmd_show,
        "update": cmd_update,
        "link": cmd_link,
        "unlink": cmd_unlink,
        "open": cmd_open,
        "launch": cmd_launch,
        "pause": cmd_pause,
        "done": cmd_done,
        "cancel": cmd_cancel,
        "reopen": cmd_reopen,
        "gc": cmd_gc,
        "reset": cmd_reset,
    }
    commands[args.command](args)


if __name__ == "__main__":
    main()
