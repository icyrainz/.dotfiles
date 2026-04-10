#!/usr/bin/env bash
# Interactive quick-add for laundry tasks (called from tmux popup via prefix+F)
set -euo pipefail

# Step 1: Get the initial prompt
echo -n "Prompt: "
read -r prompt

# Step 2: Pick working directory via zoxide + fzf
default_dir="$(tmux display-message -p '#{pane_current_path}' 2>/dev/null || pwd)"

if command -v zoxide &>/dev/null && command -v fzf &>/dev/null; then
    dir=$(zoxide query --list 2>/dev/null | fzf --height=15 --prompt="Project: " --query="$default_dir" --select-1 || true)
fi
dir="${dir:-$default_dir}"

if [[ -z "$dir" ]]; then
    echo "No directory selected, aborting."
    exit 1
fi

# Step 3: Create and open the task
add_args=(--project "$dir")
[[ -n "$prompt" ]] && add_args+=(--prompt "$prompt")
task_id=$(laundry add "${add_args[@]}")
echo "Created task $task_id in $dir"

# Open outside the popup (popup will close, then the window appears)
tmux run-shell -b "laundry open $task_id"
