#!/usr/bin/env python3
"""Laundry Web — live dashboard for all active Claude sessions."""

import json
import os
import re
import subprocess
import sys
import time
from http.server import HTTPServer, BaseHTTPRequestHandler
from socketserver import ThreadingMixIn
from pathlib import Path
from threading import Thread, Lock

PORT = int(os.environ.get("LAUNDRY_WEB_PORT", 7777))
JIRA_DOMAIN = os.environ.get("LAUNDRY_JIRA_DOMAIN", "captain401.atlassian.net")
TASKS_FILE = Path.home() / ".local" / "share" / "laundry" / "tasks.json"
REFRESH_INTERVAL = 1.5  # seconds between SSE pushes
PR_CACHE_TTL = 60       # seconds between PR status refreshes

STATUS_ORDER = {"active": 0, "pending": 1, "paused": 2, "completed": 3, "cancelled": 4}

# PR status cache: {"owner/repo#123": "APPROVED"} — refreshed by background thread
_pr_cache = {}
_pr_cache_lock = Lock()

HTML_FILE = Path(__file__).resolve().parent / "laundry-web.html"

_HTML_FALLBACK = (
    '<!DOCTYPE html><html><head><meta charset="utf-8"><title>laundry</title></head>'
    '<body style="background:#1a1b26;color:#c0caf5;font-family:monospace;padding:40px;text-align:center">'
    '<h2>laundry-web.html not found</h2>'
    f'<p>Expected at: {Path(__file__).resolve().parent / "laundry-web.html"}</p>'
    '</body></html>'
)



def _load_html():
    """Load HTML from external file, or show error page."""
    if HTML_FILE.exists():
        return HTML_FILE.read_text()
    return _HTML_FALLBACK


def load_tasks():
    if not TASKS_FILE.exists():
        return []
    with open(TASKS_FILE) as f:
        data = json.load(f)
    return data.get("tasks", [])


def tmux_window_info():
    try:
        result = subprocess.run(
            ["tmux", "list-windows", "-a", "-F",
             "#{session_name}:#{window_id}\t#{window_name}"],
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


def _fetch_pr_status(pr_ref):
    """Fetch PR review status from GitHub. Returns APPROVED/CHANGES_REQUESTED/MERGED/CLOSED/PENDING."""
    try:
        repo, num = pr_ref.rsplit("#", 1) if "#" in pr_ref else ("", pr_ref)
        result = subprocess.run(
            ["gh", "pr", "view", num, "-R", repo, "--json", "state,reviewDecision"],
            capture_output=True, text=True, timeout=10,
        )
        if result.returncode == 0:
            d = json.loads(result.stdout)
            if d.get("state") == "MERGED":
                return "MERGED"
            if d.get("state") == "CLOSED":
                return "CLOSED"
            return d.get("reviewDecision") or "PENDING"
    except Exception:
        pass
    return "PENDING"


def _pr_cache_loop():
    """Background thread: refresh PR statuses every PR_CACHE_TTL seconds."""
    while True:
        try:
            tasks = load_tasks()
            all_prs = set()
            for t in tasks:
                for pr in t.get("links", {}).get("prs", []):
                    all_prs.add(pr)
            for pr in all_prs:
                status = _fetch_pr_status(pr)
                with _pr_cache_lock:
                    _pr_cache[pr] = status
        except Exception:
            pass
        time.sleep(PR_CACHE_TTL)


def capture_pane(target):
    result = subprocess.run(
        ["tmux", "capture-pane", "-t", target, "-p", "-J"],
        capture_output=True, text=True,
    )
    lines = (result.stdout or "").rstrip().splitlines()
    content = "\n".join(lines[:-6]) if len(lines) > 6 else result.stdout or ""
    return content


def get_claude_states():
    """Read @claude-state from all tmux windows in one call. Returns {target: state}."""
    try:
        result = subprocess.run(
            ["tmux", "list-windows", "-a", "-F",
             "#{session_name}:#{window_id}\t#{@claude-state}"],
            capture_output=True, text=True,
        )
        states = {}
        for line in result.stdout.splitlines():
            parts = line.split("\t", 1)
            if len(parts) == 2:
                target = parts[0]
                raw = parts[1].strip()
                if raw == "▶":
                    states[target] = "thinking"
                elif raw == "●":
                    states[target] = "permission"
                elif raw == "■":
                    states[target] = "idle"
                else:
                    states[target] = "idle"
        return states
    except Exception:
        return {}


def _relative_time(iso_str):
    try:
        from datetime import datetime, timezone
        dt = datetime.strptime(iso_str, "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=timezone.utc)
        secs = int((datetime.now(timezone.utc) - dt).total_seconds())
        if secs < 60: return f"{secs}s"
        if secs < 3600: return f"{secs // 60}m"
        if secs < 86400: return f"{secs // 3600}h"
        return f"{secs // 86400}d"
    except Exception:
        return ""


def get_dashboard_data():
    tasks = load_tasks()
    windows = tmux_window_info()
    active = [
        t for t in tasks
        if t["status"] == "active" and t.get("tmux_window_id")
        and t["tmux_window_id"] in windows
    ]
    active.sort(key=lambda t: (
        STATUS_ORDER.get(t["status"], 9),
        -(time.mktime(time.strptime(t["updated_at"], "%Y-%m-%dT%H:%M:%SZ"))
          if t.get("updated_at") else 0),
    ))
    result = []
    claude_states = get_claude_states()
    for t in active:
        content = capture_pane(t["tmux_window_id"])
        session_state = claude_states.get(t["tmux_window_id"], "idle")
        project = Path(t["project"]).name if t.get("project") else ""
        title = t.get("title") or t.get("initial_prompt", "")[:40] or t["id"]
        # Build compact link labels
        prs = t.get("links", {}).get("prs", [])
        jiras = t.get("links", {}).get("jira", [])
        links = []
        for j in jiras:
            links.append({"label": j, "url": f"https://{JIRA_DOMAIN}/browse/{j}", "type": "jira"})
        for pr in prs:
            repo, num = pr.rsplit("#", 1) if "#" in pr else ("", pr)
            with _pr_cache_lock:
                status = _pr_cache.get(pr, "PENDING")
            links.append({
                "label": f"PR#{num}",
                "url": f"https://github.com/{repo}/pull/{num}",
                "type": "pr",
                "status": status,
            })
        result.append({
            "id": t["id"],
            "project": project,
            "title": title,
            "target": t["tmux_window_id"],
            "content": content,
            "links": links,
            "state": session_state,
            "age": _relative_time(t.get("updated_at", "")),
        })
    paused_count = sum(1 for t in tasks if t["status"] == "paused")
    return {"tasks": result, "paused_count": paused_count}


def send_to_pane(task_id, text):
    tasks = load_tasks()
    for t in tasks:
        if t["id"] == task_id and t.get("tmux_window_id"):
            target = t["tmux_window_id"]
            if text:
                subprocess.run(
                    ["tmux", "send-keys", "-t", target, text, "Enter"],
                    capture_output=True,
                )
            else:
                # Bare Enter (quick approve)
                subprocess.run(
                    ["tmux", "send-keys", "-t", target, "Enter"],
                    capture_output=True,
                )
            return True
    return False


ALLOWED_ACTIONS = {"pause", "done", "cancel", "delete", "open"}


def get_project_dirs():
    """Get project directories from zoxide (most frequent first)."""
    try:
        result = subprocess.run(
            ["zoxide", "query", "--list"],
            capture_output=True, text=True, timeout=5,
        )
        if result.returncode == 0:
            return [d.strip() for d in result.stdout.splitlines() if d.strip()][:20]
    except Exception:
        pass
    return [str(Path.home() / "Github")]


def add_and_open_task(prompt, project):
    """Create a task and open it. Returns task_id or None."""
    laundry_bin = Path(__file__).resolve().parent / "laundry.py"
    args = [sys.executable, str(laundry_bin), "add"]
    if prompt:
        args += [prompt, "--prompt", prompt]
    if project:
        args += ["--project", project]
    result = subprocess.run(args, capture_output=True, text=True)
    if result.returncode != 0:
        return None
    task_id = result.stdout.strip()
    # Open the task (creates tmux window + Claude)
    subprocess.run(
        [sys.executable, str(laundry_bin), "open", task_id],
        capture_output=True, text=True,
    )
    return task_id


def run_task_action(task_id, action):
    """Run a laundry CLI action on a task."""
    if action not in ALLOWED_ACTIONS:
        return False
    laundry_bin = Path(__file__).resolve().parent / "laundry.py"
    result = subprocess.run(
        [sys.executable, str(laundry_bin), action, task_id],
        capture_output=True, text=True,
    )
    return result.returncode == 0


class Handler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass  # silence request logs

    def do_GET(self):
        if self.path == "/":
            self.send_response(200)
            self.send_header("Content-Type", "text/html")
            self.end_headers()
            self.wfile.write(_load_html().encode())
        elif self.path == "/events":
            self.send_response(200)
            self.send_header("Content-Type", "text/event-stream")
            self.send_header("Cache-Control", "no-cache")
            self.send_header("Connection", "keep-alive")
            self.end_headers()
            try:
                while True:
                    data = get_dashboard_data()
                    payload = f"data: {json.dumps(data)}\n\n"
                    self.wfile.write(payload.encode())
                    self.wfile.flush()
                    time.sleep(REFRESH_INTERVAL)
            except (BrokenPipeError, ConnectionResetError):
                pass
        elif self.path == "/projects":
            dirs = get_project_dirs()
            self._json_response(200, dirs)
        elif self.path.startswith("/paused"):
            show_all = "all=1" in self.path
            tasks = load_tasks()
            statuses = {"paused", "completed", "cancelled"} if show_all else {"paused"}
            result = [
                {
                    "id": t["id"],
                    "title": t.get("title") or t.get("initial_prompt", "")[:40] or t["id"],
                    "project": Path(t["project"]).name if t.get("project") else "",
                    "age": _relative_time(t.get("updated_at", "")),
                    "status": t["status"],
                }
                for t in tasks if t["status"] in statuses
            ]
            self._json_response(200, result)
        else:
            self.send_error(404)

    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        body = json.loads(self.rfile.read(length))

        if self.path == "/send":
            ok = send_to_pane(body["task_id"], body["text"])
            self._json_response(200 if ok else 404, {"ok": ok})
        elif self.path == "/action":
            ok = run_task_action(body["task_id"], body["action"])
            self._json_response(200 if ok else 400, {"ok": ok})
        elif self.path == "/add":
            task_id = add_and_open_task(body.get("prompt", ""), body.get("project", ""))
            self._json_response(200 if task_id else 400, {"ok": bool(task_id), "task_id": task_id})
        else:
            self.send_error(404)

    def _json_response(self, code, data):
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())


def main():
    # Start background PR status fetcher
    pr_thread = Thread(target=_pr_cache_loop, daemon=True)
    pr_thread.start()

    class ThreadedServer(ThreadingMixIn, HTTPServer):
        daemon_threads = True
        def handle_error(self, request, client_address):
            # Suppress connection reset errors (browser closing SSE)
            pass

    server = ThreadedServer(("127.0.0.1", PORT), Handler)
    print(f"laundry-web → http://localhost:{PORT}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    server.server_close()


if __name__ == "__main__":
    main()
