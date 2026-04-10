#!/usr/bin/env python3
"""Laundry Web — live dashboard for all active Claude sessions."""

import json
import os
import re
import subprocess
import sys
import time
from http.server import HTTPServer, BaseHTTPRequestHandler
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

HTML = """<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>laundry</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    background: #1a1b26; color: #c0caf5; font-family: 'JetBrains Mono', 'Fira Code', monospace;
    font-size: 13px; height: 100vh; overflow: hidden;
  }
  #grid {
    display: grid; gap: 1px; height: 100vh; padding: 1px;
    background: #292e42;
  }
  .tile {
    background: #1a1b26; display: flex; flex-direction: column;
    min-height: 0; overflow: hidden;
  }
  .tile-header {
    padding: 6px 10px; font-weight: bold; color: #7aa2f7;
    border-bottom: 1px solid #292e42; flex-shrink: 0;
    display: flex; justify-content: space-between; align-items: center;
  }
  .tile-header .project { color: #565f89; margin-right: 8px; }
  .tile-header .status { font-size: 11px; color: #565f89; }
  .tile-header .links { display: flex; gap: 8px; align-items: center; }
  .tile-header .links a {
    text-decoration: none; font-size: 12px; font-weight: 600;
    padding: 1px 6px; border-radius: 3px;
  }
  .tile-header .links a:hover { text-decoration: underline; }
  .tile-header .links a.jira { color: #7dcfff; }
  .tile-header .links a.pr-PENDING { color: #e0af68; background: rgba(224,175,104,0.1); }
  .tile-header .links a.pr-REVIEW_REQUIRED { color: #e0af68; background: rgba(224,175,104,0.1); }
  .tile-header .links a.pr-APPROVED { color: #73daca; background: rgba(115,218,202,0.1); }
  .tile-header .links a.pr-CHANGES_REQUESTED { color: #f7768e; background: rgba(247,118,142,0.1); }
  .tile-header .links a.pr-MERGED { color: #bb9af7; background: rgba(187,154,247,0.1); }
  .tile-header .links a.pr-CLOSED { color: #565f89; }
  .tile-content {
    flex: 1; overflow-y: auto; padding: 6px 10px;
    white-space: pre-wrap; word-break: break-all;
    font-size: 12px; line-height: 1.4;
  }
  .tile-content::-webkit-scrollbar { width: 4px; }
  .tile-content::-webkit-scrollbar-thumb { background: #292e42; border-radius: 2px; }
  .tile-input {
    border-top: 1px solid #292e42; padding: 4px 8px; flex-shrink: 0;
    display: flex; gap: 4px;
  }
  .tile-input input {
    flex: 1; background: #24283b; color: #c0caf5; border: 1px solid #292e42;
    padding: 4px 8px; font-family: inherit; font-size: 12px;
    border-radius: 3px; outline: none;
  }
  .tile-input input:focus { border-color: #7aa2f7; }
  .tile-input button {
    background: #292e42; color: #7aa2f7; border: none; padding: 4px 10px;
    cursor: pointer; border-radius: 3px; font-family: inherit; font-size: 12px;
  }
  .tile-input button:hover { background: #343b58; }
  #empty {
    display: flex; align-items: center; justify-content: center;
    height: 100vh; color: #565f89; font-size: 16px;
  }
</style>
</head>
<body>
<div id="grid"></div>
<div id="empty" style="display:none">No active tasks</div>
<script>
const grid = document.getElementById('grid');
const empty = document.getElementById('empty');
const tiles = {};
let autoScroll = {};

function updateGrid(tasks) {
  if (tasks.length === 0) {
    grid.style.display = 'none';
    empty.style.display = 'flex';
    return;
  }
  grid.style.display = 'grid';
  empty.style.display = 'none';

  // Calculate grid dimensions
  const cols = tasks.length <= 1 ? 1 : tasks.length <= 4 ? 2 : 3;
  const rows = Math.ceil(tasks.length / cols);
  grid.style.gridTemplateColumns = `repeat(${cols}, 1fr)`;
  grid.style.gridTemplateRows = `repeat(${rows}, 1fr)`;

  // Track which tiles exist
  const seen = new Set();

  tasks.forEach(t => {
    seen.add(t.id);
    if (!tiles[t.id]) {
      // Create new tile
      const tile = document.createElement('div');
      tile.className = 'tile';
      const linksHtml = (t.links || []).map(l => {
        const cls = l.type === 'jira' ? 'jira' : `pr-${l.status || 'PENDING'}`;
        return `<a href="${esc(l.url)}" target="_blank" class="${cls}">${esc(l.label)}</a>`;
      }).join('');
      tile.innerHTML = `
        <div class="tile-header">
          <span><span class="project">${esc(t.project)}</span>${esc(t.title)}</span>
          <span class="links">${linksHtml}</span>
        </div>
        <div class="tile-content" id="content-${t.id}"></div>
        <div class="tile-input">
          <input type="text" placeholder="send input..." id="input-${t.id}"
                 onkeydown="if(event.key==='Enter')sendInput('${t.id}',this.value,this)">
          <button onclick="sendInput('${t.id}',document.getElementById('input-${t.id}').value,document.getElementById('input-${t.id}'))">↵</button>
        </div>`;
      grid.appendChild(tile);
      tiles[t.id] = tile;
      autoScroll[t.id] = true;

      // Track scroll position
      const content = tile.querySelector('.tile-content');
      content.addEventListener('scroll', () => {
        const atBottom = content.scrollHeight - content.scrollTop - content.clientHeight < 30;
        autoScroll[t.id] = atBottom;
      });
    }

    // Update content
    const content = document.getElementById('content-' + t.id);
    if (content && t.content !== undefined) {
      content.textContent = t.content;
      if (autoScroll[t.id]) {
        content.scrollTop = content.scrollHeight;
      }
    }

    // Update links
    const linksEl = tiles[t.id].querySelector('.links');
    if (linksEl && t.links) {
      linksEl.innerHTML = t.links.map(l =>
        `<a href="${esc(l.url)}" target="_blank">${esc(l.label)}</a>`
      ).join('');
    }
  });

  // Remove stale tiles
  Object.keys(tiles).forEach(id => {
    if (!seen.has(id)) {
      tiles[id].remove();
      delete tiles[id];
      delete autoScroll[id];
    }
  });
}

function esc(s) {
  const d = document.createElement('div');
  d.textContent = s || '';
  return d.innerHTML;
}

function sendInput(taskId, text, input) {
  if (!text) return;
  fetch('/send', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({task_id: taskId, text: text})
  });
  input.value = '';
}

// SSE connection
function connect() {
  const es = new EventSource('/events');
  es.onmessage = (e) => {
    try { updateGrid(JSON.parse(e.data)); } catch(err) {}
  };
  es.onerror = () => {
    es.close();
    setTimeout(connect, 2000);
  };
}
connect();
</script>
</body>
</html>"""


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
    # Drop last 6 lines (Claude TUI chrome)
    lines = (result.stdout or "").rstrip().splitlines()
    return "\n".join(lines[:-6]) if len(lines) > 6 else result.stdout or ""


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
    for t in active:
        content = capture_pane(t["tmux_window_id"])
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
        })
    return result


def send_to_pane(task_id, text):
    tasks = load_tasks()
    for t in tasks:
        if t["id"] == task_id and t.get("tmux_window_id"):
            subprocess.run(
                ["tmux", "send-keys", "-t", t["tmux_window_id"], text, "Enter"],
                capture_output=True,
            )
            return True
    return False


class Handler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass  # silence request logs

    def do_GET(self):
        if self.path == "/":
            self.send_response(200)
            self.send_header("Content-Type", "text/html")
            self.end_headers()
            self.wfile.write(HTML.encode())
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
        else:
            self.send_error(404)

    def do_POST(self):
        if self.path == "/send":
            length = int(self.headers.get("Content-Length", 0))
            body = json.loads(self.rfile.read(length))
            ok = send_to_pane(body["task_id"], body["text"])
            self.send_response(200 if ok else 404)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"ok": ok}).encode())
        else:
            self.send_error(404)


def main():
    # Start background PR status fetcher
    pr_thread = Thread(target=_pr_cache_loop, daemon=True)
    pr_thread.start()

    server = HTTPServer(("127.0.0.1", PORT), Handler)
    print(f"laundry-web → http://localhost:{PORT}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    server.server_close()


if __name__ == "__main__":
    main()
