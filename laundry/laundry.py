#!/usr/bin/env python3
"""Laundry — task-driven Claude workspace manager."""

import json
import os
import sys
import fcntl
import uuid
import re
import socket
import signal
import subprocess
import threading
import time
from io import StringIO
from pathlib import Path
from datetime import datetime, timezone, timedelta

DATA_DIR = Path.home() / ".local" / "share" / "laundry"
TASKS_FILE = DATA_DIR / "tasks.json"
LOCK_FILE = DATA_DIR / "tasks.json.lock"
NOTES_DIR = DATA_DIR / "notes"
SOCK_FILE = DATA_DIR / "laundry.sock"
HARPOON_FILE = Path.home() / ".config" / "tmux" / "harpoon-sessions"

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


def _relative_time(iso_str, short=False):
    """Convert ISO timestamp to relative time string.

    short=False: '2m ago', '3h ago' (for show output)
    short=True:  '2m', '3h' (for compact TV list)
    """
    try:
        dt = datetime.strptime(iso_str, "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=timezone.utc)
        delta = datetime.now(timezone.utc) - dt
        secs = int(delta.total_seconds())
        suffix = "" if short else " ago"
        if secs < 0:
            return "now" if short else "just now"
        if secs < 60:
            return f"{secs}s{suffix}"
        mins = secs // 60
        if mins < 60:
            return f"{mins}m{suffix}"
        hours = mins // 60
        if hours < 24:
            return f"{hours}h{suffix}"
        days = hours // 24
        if days < 30:
            return f"{days}d{suffix}"
        months = days // 30
        return f"{months}mo{suffix}"
    except (ValueError, TypeError):
        return ""


def _home_path(path_str):
    """Replace $HOME prefix with ~ for display."""
    home = str(Path.home())
    if path_str and path_str.startswith(home):
        return "~" + path_str[len(home):]
    return path_str


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



class Tmux:
    """Encapsulates all tmux subprocess interactions."""

    @staticmethod
    def _run(*args, **kwargs):
        """Run a tmux command. Raises FileNotFoundError if tmux is missing."""
        return subprocess.run(["tmux", *args], **kwargs)

    @staticmethod
    def window_info():
        """Single call returning (windows: dict[session:@N → name]).

        Keys are full tmux targets (e.g. 'myproject:@3'), values are window names.
        """
        try:
            result = Tmux._run(
                "list-windows", "-a", "-F",
                "#{session_name}:#{window_id}\t#{window_name}",
                capture_output=True, text=True,
            )
            windows = {}
            for line in result.stdout.splitlines():
                parts = line.split("\t", 1)
                if parts:
                    windows[parts[0]] = parts[1] if len(parts) >= 2 else ""
            return windows
        except FileNotFoundError:
            return {}

    @staticmethod
    def window_exists(target):
        if not target:
            return False
        return target in Tmux.window_info()

    @staticmethod
    def session_exists(name):
        result = Tmux._run("has-session", "-t", name, capture_output=True)
        return result.returncode == 0

    @staticmethod
    def switch(window_id):
        Tmux._run("switch-client", "-t", window_id)

    @staticmethod
    def kill_window(target):
        Tmux._run("kill-window", "-t", target, capture_output=True)

    @staticmethod
    def capture_pane(target, lines=40):
        result = Tmux._run(
            "capture-pane", "-t", target, "-p",
            capture_output=True, text=True,
        )
        # Take the last N non-empty lines so preview shows the bottom
        text = (result.stdout or "").rstrip()
        trimmed = "\n".join(text.splitlines()[-lines:]) if text else ""
        return trimmed

    @staticmethod
    def display(fmt, target=None):
        """Query tmux with display-message -p. Returns stdout string."""
        cmd = ["display-message"]
        if target:
            cmd += ["-t", target]
        cmd += ["-p", fmt]
        result = Tmux._run(*cmd, capture_output=True, text=True)
        if result.returncode != 0:
            return None
        return result.stdout.strip()

    @staticmethod
    def toast(msg):
        """Show a transient tmux status-line message."""
        Tmux._run("display-message", msg, capture_output=True)

    @staticmethod
    def send_keys(target, text, enter=True):
        cmd = ["send-keys", "-t", target, text]
        if enter:
            cmd.append("Enter")
        Tmux._run(*cmd, capture_output=True)

    @staticmethod
    def new_window(session, cwd, name, fmt, command):
        """Create a new window, return formatted output (e.g. session:@N)."""
        result = Tmux._run(
            "new-window", "-t", session, "-c", cwd,
            "-n", name, "-P", "-F", fmt, *command,
            capture_output=True, text=True,
        )
        return result.stdout.strip() if result.returncode == 0 else None

    @staticmethod
    def new_session(name, cwd, window_name, fmt, command):
        """Create a new detached session, return formatted output."""
        result = Tmux._run(
            "new-session", "-d", "-s", name, "-c", cwd,
            "-n", window_name, "-P", "-F", fmt, *command,
            capture_output=True, text=True,
        )
        return result.stdout.strip() if result.returncode == 0 else None


def _kill_task_window(task):
    wid = task.get("tmux_window_id")
    if wid:
        Tmux.kill_window(wid)


SYSTEM_PROMPT_FILE = DATA_DIR / "system-prompt.md"


def _build_system_prompt(task):
    tid = task["id"]
    notes_path = NOTES_DIR / task["notes_file"]
    header = f"Laundry task ID: {tid}\nNotes file: {notes_path}\n\n"
    try:
        body = SYSTEM_PROMPT_FILE.read_text().replace("<ID>", tid)
    except FileNotFoundError:
        body = ""
    return header + body


# --- daemon client ---


def _daemon_request(request):
    """Send a request to the daemon, return response string or None if daemon not running."""
    if not SOCK_FILE.exists():
        return None
    sock = None
    try:
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.settimeout(2)
        sock.connect(str(SOCK_FILE))
        sock.sendall(json.dumps(request).encode() + b"\n")
        chunks = []
        while True:
            chunk = sock.recv(65536)
            if not chunk:
                break
            chunks.append(chunk)
        resp = json.loads(b"".join(chunks).decode())
        return resp
    except (ConnectionRefusedError, FileNotFoundError, OSError, json.JSONDecodeError):
        return None
    finally:
        if sock:
            sock.close()


def _notify_daemon():
    """Tell the daemon to reload tasks from disk."""
    _daemon_request({"cmd": "reload"})


# --- output helpers (work for both direct and daemon modes) ---


def _harpoon_slots():
    """Read harpoon file → {target: slot_number}. Format: session:@N per line."""
    try:
        lines = HARPOON_FILE.read_text().splitlines()
    except FileNotFoundError:
        return {}
    slots = {}
    for i, line in enumerate(lines):
        target = line.strip()
        if target:
            slots[target] = i + 1
    return slots


STATUS_ORDER = {"active": 0, "pending": 1, "paused": 2, "completed": 3, "cancelled": 4}


def _sort_tasks(tasks):
    """Sort by status priority (active first), then most recently updated."""
    return sorted(tasks, key=lambda t: (
        STATUS_ORDER.get(t["status"], 9),
        -(datetime.strptime(t["updated_at"], "%Y-%m-%dT%H:%M:%SZ").timestamp()
          if t.get("updated_at") else 0),
    ))


def _format_list(data, status_filter=None, show_all=False, parent=None, fmt=None):
    """Generate list output as a string."""
    tasks = data["tasks"]

    if status_filter:
        tasks = [t for t in tasks if t["status"] == status_filter]
    elif not show_all:
        tasks = [t for t in tasks if t["status"] in ("pending", "active", "paused")]

    if parent:
        tasks = [t for t in tasks if t.get("parent_id") == parent]

    tasks = _sort_tasks(tasks)

    out = StringIO()
    if fmt == "tv":
        if not tasks:
            return "No task\n"

        DIM = "\033[2m"
        YELLOW = "\033[33m"
        RESET = "\033[0m"
        slots = _harpoon_slots()
        for t in tasks:
            icon = STATUS_ICONS.get(t["status"], "?")
            project = (Path(t["project"]).name[:12] if t["project"] else "").ljust(12)
            raw_title = t["title"] or t.get("initial_prompt", "")[:40] or "(untitled)"
            title = raw_title[:40].ljust(40)
            target = t.get("tmux_window_id") or ""
            pin = str(slots[target]) if target in slots else " "
            age = _relative_time(t.get("updated_at", ""), short=True).rjust(4)
            # ID is first field (hidden by display template, used by {split: :0})
            if t["status"] in ("completed", "cancelled"):
                out.write(f"{t['id']} {DIM}{icon} {pin} {project} {title} {age}{RESET}\n")
            elif t["status"] == "paused":
                out.write(f"{t['id']} {YELLOW}{icon} {pin} {project} {title} {age}{RESET}\n")
            else:
                out.write(f"{t['id']} {icon} {pin} {project} {title} {age}\n")
    else:
        for t in tasks:
            icon = STATUS_ICONS.get(t["status"], "?")
            title = t["title"] or t.get("initial_prompt", "")[:60] or "(untitled)"
            parent_str = f"  ↳ child of {t['parent_id']}" if t.get("parent_id") else ""
            out.write(f"  {icon} {t['id']}  {title}{parent_str}\n")
    return out.getvalue()


def _format_show(data, task_id, notes_file_only=False):
    """Generate show output as a string."""
    task = _find_task(data, task_id)
    if not task:
        return None

    if notes_file_only:
        return str(NOTES_DIR / task["notes_file"]) + "\n"

    out = StringIO()
    icon = STATUS_ICONS.get(task["status"], "?")
    title = task["title"] or "(untitled)"
    prs = task.get("links", {}).get("prs", [])
    jira = task.get("links", {}).get("jira", [])
    created_rel = _relative_time(task['created_at'])
    updated_rel = _relative_time(task['updated_at'])

    out.write(f"{icon} {title}\n")
    out.write(f"  Status:  {task['status']}\n")
    out.write(f"  Project: {_home_path(task['project'])}\n")
    out.write(f"  Tmux ID: {task.get('tmux_window_id') or '-'}\n")
    out.write(f"  Parent:  {task.get('parent_id') or '-'}\n")
    out.write(f"  PRs:     {', '.join(prs) if prs else '-'}\n")
    out.write(f"  Jira:    {', '.join(jira) if jira else '-'}\n")
    out.write(f"  Created: {task['created_at']} ({created_rel})\n")
    out.write(f"  Updated: {task['updated_at']} ({updated_rel})\n")

    notes_path = NOTES_DIR / task["notes_file"]
    if notes_path.exists():
        content = notes_path.read_text().strip()
        if content:
            out.write(f"\n--- Notes ---\n{content}\n")
    return out.getvalue()


def _format_pane(data, task_id):
    """Capture tmux pane content for a task."""
    task = _find_task(data, task_id)
    if not task:
        return None

    wid = task.get("tmux_window_id")
    if not wid or not Tmux.window_exists(wid):
        return f"No active window for task {task_id}\n"

    return Tmux.capture_pane(wid)


# --- daemon server ---


class LaundryDaemon:
    def __init__(self):
        self.data = {"version": 1, "tasks": []}
        self.data_mtime = 0
        self._lock = threading.Lock()
        self.running = True
        self.started_at = _now_iso()

    def reload(self):
        """Reload tasks from disk if changed."""
        try:
            mtime = TASKS_FILE.stat().st_mtime if TASKS_FILE.exists() else 0
        except OSError:
            mtime = 0
        if mtime != self.data_mtime:
            with self._lock:
                self.data = _load()
                self.data_mtime = mtime

    def gc_loop(self):
        """Background thread: poll tmux every 2s, auto-pause orphaned tasks."""
        while self.running:
            time.sleep(2)
            try:
                self._gc_once()
            except Exception:
                pass

    def _gc_once(self):
        with self._lock:
            # Quick check without file lock — skip if nothing to do
            self.data = _load()
            active_tasks = [
                t for t in self.data["tasks"]
                if t["status"] == "active" and t.get("tmux_window_id")
            ]
            if not active_tasks:
                return

            windows = Tmux.window_info()

            # Re-load under file lock to avoid overwriting concurrent writes
            # (e.g. cmd_open storing a window_id between our load and save)
            with open(LOCK_FILE, "w") as lock:
                fcntl.flock(lock, fcntl.LOCK_EX)
                self.data = _load()
                changed = False
                for task in self.data["tasks"]:
                    if task["status"] != "active" or not task.get("tmux_window_id"):
                        continue
                    target = task["tmux_window_id"]
                    if target not in windows:
                        task["tmux_window_id"] = None
                        task["status"] = "paused"
                        task["updated_at"] = _now_iso()
                        changed = True
                    else:
                        # Sync tmux window name → laundry title (3-way sync)
                        wname = windows[target]
                        # Skip the default L{task_id} name
                        if wname and wname != f"L{task['id']}" and wname != task.get("title"):
                            task["title"] = wname
                            task["updated_at"] = _now_iso()
                            changed = True
                if changed:
                    _save(self.data)
                self.data_mtime = TASKS_FILE.stat().st_mtime if TASKS_FILE.exists() else 0

    def handle_request(self, request):
        """Handle a single request, return response dict."""
        self.reload()
        cmd = request.get("cmd", "")

        if cmd == "reload":
            with self._lock:
                self.data = _load()
                self.data_mtime = TASKS_FILE.stat().st_mtime if TASKS_FILE.exists() else 0
            return {"output": "ok"}

        elif cmd == "list":
            output = _format_list(
                self.data,
                status_filter=request.get("status"),
                show_all=request.get("all", False),
                parent=request.get("parent"),
                fmt=request.get("format"),
            )
            return {"output": output}

        elif cmd == "show":
            output = _format_show(
                self.data, request["id"],
                notes_file_only=request.get("notes_file", False),
            )
            if output is None:
                return {"error": f"Task {request['id']} not found"}
            return {"output": output}

        elif cmd == "pane":
            output = _format_pane(self.data, request["id"])
            if output is None:
                return {"error": f"Task {request['id']} not found"}
            return {"output": output}

        elif cmd == "status":
            return {"started_at": self.started_at}

        return {"error": f"Unknown command: {cmd}"}

    def serve(self):
        """Main daemon loop."""
        _ensure_dirs()
        self.reload()

        # Clean up stale socket
        if SOCK_FILE.exists():
            try:
                test = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
                test.settimeout(1)
                test.connect(str(SOCK_FILE))
                test.close()
                print("Daemon already running", file=sys.stderr)
                sys.exit(0)
            except (ConnectionRefusedError, OSError):
                SOCK_FILE.unlink(missing_ok=True)

        server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        server.bind(str(SOCK_FILE))
        server.listen(5)
        server.settimeout(1)

        # Start GC thread
        gc_thread = threading.Thread(target=self.gc_loop, daemon=True)
        gc_thread.start()

        def shutdown(signum, frame):
            self.running = False

        signal.signal(signal.SIGTERM, shutdown)
        signal.signal(signal.SIGINT, shutdown)

        while self.running:
            try:
                conn, _ = server.accept()
            except socket.timeout:
                continue
            except OSError:
                break
            try:
                conn.settimeout(2)
                raw = b""
                while b"\n" not in raw and len(raw) < 65536:
                    chunk = conn.recv(4096)
                    if not chunk:
                        break
                    raw += chunk
                if raw:
                    request = json.loads(raw.decode().strip())
                    response = self.handle_request(request)
                    conn.sendall(json.dumps(response).encode())
            except Exception:
                pass
            finally:
                conn.close()

        server.close()
        SOCK_FILE.unlink(missing_ok=True)


# --- commands ---


def _create_task(*, title="", project=None, parent_id=None, prompt="",
                  status="pending", tmux_window_id=None, launched=False):
    """Create a new task under lock, write notes file, notify daemon. Returns task_id."""
    _ensure_dirs()
    project = project or str(Path.home() / "Github" / ".dotfiles")
    slug_source = title or prompt or Path(project).name or "task"

    with open(LOCK_FILE, "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        data = _load()
        task_id = _generate_id(data)
        notes_filename = f"{task_id}-{_slugify(slug_source)}.md"

        task = {
            "id": task_id,
            "title": title,
            "description": "",
            "status": status,
            "parent_id": parent_id,
            "project": project,
            "initial_prompt": prompt,
            "tmux_window_id": tmux_window_id,
            "claude_session_id": None,
            "launched": launched,
            "links": {"prs": [], "jira": []},
            "notes_file": notes_filename,
            "created_at": _now_iso(),
            "updated_at": _now_iso(),
        }
        data["tasks"].append(task)
        _save(data)

    notes_path = NOTES_DIR / notes_filename
    if not notes_path.exists():
        notes_path.touch()

    _notify_daemon()
    return task_id, task


def cmd_add(args):
    project = (
        str(Path(args.project).expanduser().resolve())
        if args.project
        else None
    )
    task_id, _ = _create_task(
        title=args.title or "",
        project=project,
        parent_id=args.parent,
        prompt=args.prompt or args.title or "",
    )
    print(task_id)
    return task_id


def _detect_task_in_pane():
    """Try to find an existing laundry task ID from the Claude process in the current tmux pane.

    Checks (in order):
    1. Pane PID args — works when Claude was launched via execvp
    2. Window name L{task_id} — set by laundry open before slug watcher renames
    3. Window name matches a known task title — set by slug watcher + daemon sync
    """
    try:
        info = Tmux.display("#{pane_pid}\t#{window_name}")
        if not info:
            return None
        parts = info.split("\t", 1)
        pane_pid = parts[0]
        window_name = parts[1] if len(parts) > 1 else ""

        # 1. Pane PID is the claude process itself (execvp launch)
        if pane_pid:
            ps_result = subprocess.run(
                ["ps", "-p", pane_pid, "-o", "args="],
                capture_output=True, text=True,
            )
            if ps_result.returncode == 0:
                m = re.search(r"Laundry task ID: (\d{8}-\d{6})", ps_result.stdout)
                if m:
                    return m.group(1)

        # 2. Window name is L{task_id}
        if window_name:
            m = re.match(r"^L(\d{8}-\d{6})$", window_name)
            if m:
                return m.group(1)

        # 3. Window name matches a task title (slug name synced by daemon)
        if window_name:
            data = _load()
            for task in data["tasks"]:
                if task.get("title") == window_name and task["status"] in ("active", "paused"):
                    return task["id"]
    except Exception:
        pass
    return None


def cmd_attach(args):
    """Attach the current tmux window to laundry, reattaching existing tasks if detected."""
    # Gather info from the current tmux window
    info = Tmux.display("#{session_name}:#{window_id}\t#{window_name}\t#{pane_current_path}")
    if info is None:
        print("Not inside a tmux session", file=sys.stderr)
        sys.exit(1)
    parts = info.split("\t")
    tmux_target = parts[0]   # e.g. voyage:@2
    window_name = parts[1] if len(parts) > 1 else ""
    pane_cwd = parts[2] if len(parts) > 2 else ""

    # Try to detect an existing task from the running Claude process
    detected_id = _detect_task_in_pane()
    if detected_id:
        _ensure_dirs()
        with open(LOCK_FILE, "w") as lock:
            fcntl.flock(lock, fcntl.LOCK_EX)
            data = _load()
            for task in data["tasks"]:
                if task["id"] == detected_id:
                    task["tmux_window_id"] = tmux_target
                    task["status"] = "active"
                    task["updated_at"] = _now_iso()
                    _save(data)
                    _notify_daemon()
                    Tmux.toast(f"harpoon reattached → {detected_id}")
                    print(detected_id)
                    return detected_id

    # No existing task found — create a new one
    shell_names = {"bash", "fish", "zsh", "sh"}
    title = window_name if window_name and window_name not in shell_names else ""

    task_id, task = _create_task(
        title=title,
        project=pane_cwd or None,
        status="active",
        tmux_window_id=tmux_target,
        launched=True,
    )

    # Send context to the running Claude session via tmux
    notes_path = NOTES_DIR / task["notes_file"]
    nudge = (
        f"This session is now tracked as laundry task #{task_id}. "
        f"Notes file: {notes_path}. "
        f"Read {SYSTEM_PROMPT_FILE} for task management commands and follow them."
    )
    Tmux.send_keys(tmux_target, nudge)
    Tmux.toast(f"harpoon attached → {task_id}")
    return task_id


def cmd_list(args):
    _ensure_dirs()
    data = _load()
    sys.stdout.write(_format_list(
        data,
        status_filter=args.status,
        show_all=args.all,
        parent=args.parent,
        fmt=args.format,
    ))


def cmd_show(args):
    _ensure_dirs()
    data = _load()
    output = _format_show(data, args.id, notes_file_only=args.notes_file)
    if output is None:
        print(f"Task {args.id} not found", file=sys.stderr)
        sys.exit(1)
    sys.stdout.write(output)


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
    _notify_daemon()
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
    _notify_daemon()
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
    _notify_daemon()
    print(f"Unlinked {args.id}")


def cmd_open(args):
    _ensure_dirs()

    # Single tmux query
    windows = Tmux.window_info()

    # Quick check without lock — if already active with valid window, just switch
    data = _load()
    task = _find_task(data, args.id)
    if not task:
        print(f"Task {args.id} not found", file=sys.stderr)
        sys.exit(1)

    target = task.get("tmux_window_id") or ""
    if task["status"] == "active" and target in windows:
        Tmux.switch(target)
        return

    # Reconcile: find dangling window for this task (e.g. after done/cancel failed to kill)
    if not target:
        l_name = f"L{task['id']}"
        title = task.get("title", "")
        for wid, wname in windows.items():
            if wname == l_name or (title and wname == title):
                target = wid
                break

    # Need to mutate — acquire lock
    with open(LOCK_FILE, "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        data = _load()
        task = _find_task(data, args.id)

        # Re-check after lock (another process may have changed state)
        if task["status"] == "active" and (task.get("tmux_window_id") or "") in windows:
            Tmux.switch(task["tmux_window_id"])
            return

        if task["status"] in ("completed", "cancelled"):
            task["status"] = "pending"
        elif task["status"] not in ("pending", "paused"):
            print(f"Cannot open task in '{task['status']}' state", file=sys.stderr)
            sys.exit(1)

        # Reconcile: if we found a dangling window pre-lock, re-associate and switch
        if target and target in windows and not task.get("tmux_window_id"):
            task["tmux_window_id"] = target
            task["status"] = "active"
            task["updated_at"] = _now_iso()
            _save(data)
            _notify_daemon()
            Tmux.switch(target)
            return

        if not task.get("claude_session_id"):
            task["claude_session_id"] = str(uuid.uuid4())

        # Update state before spawning tmux (so daemon GC doesn't race)
        task["status"] = "active"
        task["updated_at"] = _now_iso()
        _save(data)

    # tmux operations outside lock
    project_path = Path(task["project"])
    session_name = project_path.name.replace(".", "_")  # tmux maps dots to underscores
    laundry_bin = Path(__file__).resolve()

    tmux_fmt = "#{session_name}:#{window_id}"
    window_name = f"L{task['id']}"
    launch_cmd = ["python3", str(laundry_bin), "launch", task["id"]]

    if not Tmux.session_exists(session_name):
        # Create session with the task as the initial window (no orphan shell)
        window_id = Tmux.new_session(
            session_name, str(project_path), window_name, tmux_fmt, launch_cmd,
        )
        # Race: another process created the session first — fall back to new-window
        if not window_id:
            window_id = Tmux.new_window(
                session_name, str(project_path), window_name, tmux_fmt, launch_cmd,
            )
    else:
        window_id = Tmux.new_window(
            session_name, str(project_path), window_name, tmux_fmt, launch_cmd,
        )

    # Store window ID
    with open(LOCK_FILE, "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        data = _load()
        task = _find_task(data, args.id)
        task["tmux_window_id"] = window_id
        _save(data)

    _notify_daemon()
    Tmux.switch(window_id)


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
    _notify_daemon()

    if is_resume:
        # Try resume; only fall back to fresh start if session not found
        result = subprocess.run(
            ["claude", "--resume", session_id, "--append-system-prompt", system_prompt],
            capture_output=False, text=True, stderr=subprocess.PIPE,
        )
        if result.returncode != 0 and "No conversation found" in (result.stderr or ""):
            # Session doesn't exist — start fresh with the same session ID
            cmd = [
                "claude",
                "--session-id", session_id,
                "--append-system-prompt", system_prompt,
                "-n", f"L{task['id']}",
            ]
            if task.get("initial_prompt"):
                cmd.append(task["initial_prompt"])
            os.execvp("claude", cmd)
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
    _notify_daemon()
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
        if task["status"] not in ("active", "paused"):
            print(f"Cannot complete task in '{task['status']}' state", file=sys.stderr)
            sys.exit(1)

        _kill_task_window(task)
        task["tmux_window_id"] = None
        task["status"] = "completed"
        task["updated_at"] = _now_iso()
        _save(data)
    _notify_daemon()
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
    _notify_daemon()
    print(f"Cancelled {args.id}")


def cmd_delete(args):
    _ensure_dirs()
    with open(LOCK_FILE, "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        data = _load()
        task = _find_task(data, args.id)
        if not task:
            print(f"Task {args.id} not found", file=sys.stderr)
            sys.exit(1)

        # Remove notes file
        notes_path = NOTES_DIR / task["notes_file"]
        notes_path.unlink(missing_ok=True)
        data["tasks"] = [t for t in data["tasks"] if t["id"] != args.id]
        _save(data)
    _notify_daemon()
    print(f"Deleted {args.id}")




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
    _notify_daemon()
    print("All tasks wiped")


def cmd_gc(args):
    _ensure_dirs()
    windows = Tmux.window_info()
    with open(LOCK_FILE, "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        data = _load()
        changed = []

        for task in data["tasks"]:
            target = task.get("tmux_window_id")
            if task["status"] == "active" and (not target or target not in windows):
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
    _notify_daemon()


def cmd_wall(args):
    """Create a tiled tmux window showing all active task panes live."""
    _ensure_dirs()
    data = _load()
    windows = Tmux.window_info()

    active = [
        t for t in _sort_tasks(data["tasks"])
        if t["status"] == "active" and t.get("tmux_window_id")
        and t["tmux_window_id"] in windows
    ]

    if not active:
        print("No active tasks with windows", file=sys.stderr)
        sys.exit(1)

    # Build a watch command for each task pane
    # Shows task title as header + live pane capture
    wall_cmds = []
    for t in active:
        target = t["tmux_window_id"]
        title = t.get("title") or t.get("initial_prompt", "")[:40] or t["id"]
        project = Path(t["project"]).name if t.get("project") else ""
        header = f"{project}: {title}"
        # watch runs capture-pane in a loop; -t for no title bar; -c for color
        cmd = (
            f"watch -n1 -t -c "
            f"'echo \"\\033[1m{header}\\033[0m\"; echo \"─────────────────────────────────\"; "
            f"tmux capture-pane -t \"{target}\" -p -e | tail -30'"
        )
        wall_cmds.append(cmd)

    # Kill existing wall session if any
    SESSION = "laundry-wall"
    Tmux._run("kill-session", "-t", SESSION, capture_output=True)

    # Create a dedicated session with the first pane
    first_cmd = wall_cmds[0]
    result = Tmux._run(
        "new-session", "-d", "-s", SESSION, "-n", "wall",
        "-P", "-F", "#{session_name}:#{window_id}",
        "bash", "-c", first_cmd,
        capture_output=True, text=True,
    )
    wall_window = result.stdout.strip()
    if not wall_window:
        print("Failed to create wall session", file=sys.stderr)
        sys.exit(1)

    # Split for each additional task
    for cmd in wall_cmds[1:]:
        Tmux._run(
            "split-window", "-t", wall_window,
            "bash", "-c", cmd,
            capture_output=True,
        )
        # Re-tile after each split to keep layout balanced
        Tmux._run("select-layout", "-t", wall_window, "tiled", capture_output=True)

    # Final tiled layout and switch
    Tmux._run("select-layout", "-t", wall_window, "tiled", capture_output=True)
    Tmux.switch(wall_window)


def cmd_pane(args):
    _ensure_dirs()
    data = _load()
    output = _format_pane(data, args.id)
    if output is None:
        print(f"Task {args.id} not found", file=sys.stderr)
        sys.exit(1)
    sys.stdout.write(output)


def cmd_status(args):
    _ensure_dirs()
    data = _load()
    counts = {}
    for t in data["tasks"]:
        counts[t["status"]] = counts.get(t["status"], 0) + 1

    total = len(data["tasks"])
    parts = [f"{counts.get(s, 0)} {s}" for s in VALID_STATUSES if counts.get(s, 0)]
    print(f"Tasks: {total} ({', '.join(parts) if parts else 'none'})")

    # Daemon health
    resp = _daemon_request({"cmd": "status"})
    if resp and "started_at" in resp:
        uptime = _relative_time(resp["started_at"])
        print(f"Daemon: running ({uptime})")
    else:
        print("Daemon: not running")


def cmd_serve(args):
    daemon = LaundryDaemon()
    daemon.serve()


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

    # attach
    sub.add_parser("attach", help="Attach current tmux window as a new task")

    # list
    p_list = sub.add_parser("list", help="List tasks")
    p_list.add_argument("--all", "-a", action="store_true", help="Show all statuses")
    p_list.add_argument("--status", "-s", choices=VALID_STATUSES, help="Filter by status")
    p_list.add_argument("--parent", help="Filter by parent task ID")
    p_list.add_argument("--format", "-f", choices=["tv"], help="Output format")

    # show
    p_show = sub.add_parser("show", help="Show task detail")
    p_show.add_argument("id", help="Task ID")
    p_show.add_argument("--notes-file", action="store_true", help="Print notes file path only")

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

    # delete
    p_delete = sub.add_parser("delete", help="Delete a single task")
    p_delete.add_argument("id", help="Task ID")


    # wall
    sub.add_parser("wall", help="Tiled live view of all active task panes")

    # gc
    sub.add_parser("gc", help="Reconcile: pause tasks with missing tmux windows")

    # pane
    p_pane = sub.add_parser("pane", help="Capture tmux pane content for a task")
    p_pane.add_argument("id", help="Task ID")

    # status
    sub.add_parser("status", help="Show task counts and daemon health")

    # serve
    sub.add_parser("serve", help="Start the laundry daemon")

    # reset
    sub.add_parser("reset", help="Wipe all tasks and notes")


    args = parser.parse_args()
    if args.command is None:
        parser.print_help()
        sys.exit(1)

    commands = {
        "add": cmd_add,
        "attach": cmd_attach,
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
        "delete": cmd_delete,
        "gc": cmd_gc,
        "wall": cmd_wall,
        "pane": cmd_pane,
        "status": cmd_status,
        "serve": cmd_serve,
        "reset": cmd_reset,
    }
    commands[args.command](args)


if __name__ == "__main__":
    main()
