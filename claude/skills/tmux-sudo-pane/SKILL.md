---
name: tmux-sudo-pane
description: Use when a command requires sudo or elevated privileges, or when the user asks to run something in a separate tmux pane, or when a bash command fails with permission denied
---

# Running Commands via Tmux Pane

Run privileged commands in a separate tmux pane and capture output back, avoiding sudo password prompts in Claude's shell.

## Prerequisite: Tmux Check

Before using this skill, verify Claude is running inside tmux:

```bash
echo "$TMUX"
```

If `$TMUX` is empty, **this skill cannot be used**. Tell the user to start Claude Code inside a tmux session first (e.g., `tmux new -s claude` then run `claude`).

## When to Use

- Command needs `sudo` and Claude can't provide password
- User says "run this in a pane" or "use a tmux pane"
- Permission denied errors on system files
- Need to interact with a root shell the user has open

## Quick Reference

| Action | Command |
|--------|---------|
| Get current session | `tmux display-message -p '#{session_name}'` |
| Get current window | `tmux display-message -p '#{window_index}'` |
| List all panes | `tmux list-panes -F '#{pane_id} #{pane_index} #{pane_current_command}'` |
| Split and get pane ID | `tmux split-window -d -P -F '#{pane_id}'` |
| Send command to pane | `tmux send-keys -t PANE_ID 'command' Enter` |
| Capture pane output | `tmux capture-pane -t PANE_ID -p -S -N` |
| Close pane | `tmux send-keys -t PANE_ID 'exit' Enter` |

## Workflow

### 1. Create a pane and capture its ID

```bash
PANE_ID=$(tmux split-window -d -P -F '#{pane_id}')
echo "$PANE_ID"
```

The `-d` flag prevents the split from stealing Claude's shell. Focus is switched explicitly in step 2 so the user can interact with the pane.

### 2. Focus the pane and send a command

```bash
tmux select-pane -t "$PANE_ID"
tmux send-keys -t "$PANE_ID" 'sudo cat /etc/shadow' Enter
```

Switching focus lets the user see the pane and type their sudo password directly.

### 3. Wait for completion, then capture output

```bash
sleep 2 && tmux capture-pane -t "$PANE_ID" -p -S -30
```

`-S -30` captures the last 30 lines. Adjust as needed. Use `sleep` to allow the command to finish — increase for slow commands.

### 4. Clean up when done

```bash
tmux send-keys -t "$PANE_ID" 'exit' Enter
```

## If the User Already Has a Sudo Pane Open

Ask the user for the pane ID, or discover it:

```bash
tmux list-panes -a -F '#{pane_id} #{pane_current_command}'
```

Look for panes running `sudo`, `bash`, or `zsh` as root. Then skip step 1 and use their pane ID directly.

## Waiting for User Input (sudo password)

When the command needs sudo and the user hasn't pre-authenticated:

1. Send the command
2. Tell the user: "Please enter your sudo password in the tmux pane"
3. Poll for completion before capturing:

```bash
# Poll until prompt returns (command finished)
for i in $(seq 1 30); do
  OUTPUT=$(tmux capture-pane -t "$PANE_ID" -p -S -5)
  if echo "$OUTPUT" | grep -q '\$\|#\|❯\|>'; then
    break
  fi
  sleep 1
done
tmux capture-pane -t "$PANE_ID" -p -S -30
```

## Common Mistakes

- **Forgetting `-d` on split-window**: steals focus from Claude's pane, breaking the session
- **Not waiting long enough**: capturing output before command finishes returns incomplete results
- **Using pane index instead of ID**: pane indices change when panes are rearranged; `%N` IDs are stable
- **Capturing too few lines**: `-S -30` may miss output from long commands; use `-S -` for entire scrollback
