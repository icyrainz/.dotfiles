#!/usr/bin/env bash
set -euo pipefail

COLOR_GREEN="#98c379"
COLOR_YELLOW="#e5c07b"
COLOR_RED="#e06c75"
COLOR_BLUE="#61afef"
COLOR_GRAY="#5c6370"

get_pr_indicator() {
    local pane_path="$1"

    local branch
    branch=$(git -C "$pane_path" branch --show-current 2>/dev/null) || return 0
    [ -z "$branch" ] && return 0

    case "$branch" in
        main|master|develop) return 0 ;;
    esac

    local repo_root
    repo_root=$(git -C "$pane_path" rev-parse --show-toplevel 2>/dev/null) || return 0

    local pr_json
    pr_json=$(cd "$repo_root" && gh pr view "$branch" --json state,statusCheckRollup,reviewDecision 2>/dev/null) || return 0

    local state review_decision
    state=$(echo "$pr_json" | grep -o '"state":"[^"]*"' | head -1 | sed 's/"state":"//;s/"//')
    review_decision=$(echo "$pr_json" | grep -o '"reviewDecision":"[^"]*"' | head -1 | sed 's/"reviewDecision":"//;s/"//')

    local has_pending=false has_failure=false
    if echo "$pr_json" | grep -q '"status":"PENDING"' 2>/dev/null; then
        has_pending=true
    fi
    if echo "$pr_json" | grep -qE '"(status|conclusion)":"(FAILURE|ERROR)"' 2>/dev/null; then
        has_failure=true
    fi

    if [ "$state" = "MERGED" ]; then
        echo " #[fg=${COLOR_GRAY}]✓"
    elif [ "$state" = "CLOSED" ]; then
        echo ""
    elif [ "$has_failure" = true ]; then
        echo " #[fg=${COLOR_RED}]✗"
    elif [ "$has_pending" = true ]; then
        echo " #[fg=${COLOR_YELLOW}]⟳"
    elif [ "$review_decision" = "CHANGES_REQUESTED" ]; then
        echo " #[fg=${COLOR_RED}]✗"
    elif [ "$review_decision" = "APPROVED" ]; then
        echo " #[fg=${COLOR_GREEN}]✓"
    else
        echo " #[fg=${COLOR_BLUE}]●"
    fi
}

is_worktree() {
    local path="$1"
    local git_dir
    git_dir=$(git -C "$path" rev-parse --git-dir 2>/dev/null) || return 1
    # In a worktree, git-dir contains "/worktrees/"
    [[ "$git_dir" == *"/worktrees/"* ]]
}

update_session() {
    local session="$1"

    # Get the active window's pane path as the session's current context
    local active_path
    active_path=$(tmux display-message -t "${session}" -p '#{pane_current_path}' 2>/dev/null) || return 0
    [ -z "$active_path" ] && return 0

    local indicator
    indicator=$(get_pr_indicator "$active_path")
    tmux set-option -t "$session" @pr-session-indicator "$indicator" 2>/dev/null || true

    # Get main repo root for worktree comparison
    local main_repo_root
    main_repo_root=$(git -C "$active_path" rev-parse --show-toplevel 2>/dev/null) || main_repo_root=""

    # Per-window: only set indicator for worktree windows
    tmux list-windows -t "$session" -F '#{window_index}' 2>/dev/null | while IFS= read -r win_idx; do
        local target="${session}:${win_idx}"
        local win_path
        win_path=$(tmux display-message -t "$target" -p '#{pane_current_path}' 2>/dev/null) || continue
        [ -z "$win_path" ] && continue

        local win_repo_root
        win_repo_root=$(git -C "$win_path" rev-parse --show-toplevel 2>/dev/null) || win_repo_root=""

        if [ -n "$win_repo_root" ] && [ "$win_repo_root" != "$main_repo_root" ] && is_worktree "$win_path"; then
            # Worktree window — set its own indicator
            local win_indicator
            win_indicator=$(get_pr_indicator "$win_path")
            tmux set-option -w -t "$target" @pr-indicator "$win_indicator" 2>/dev/null || true
        else
            # Same repo as session — clear per-window indicator
            tmux set-option -w -t "$target" @pr-indicator "" 2>/dev/null || true
        fi
    done
}

if [ "${1:-}" = "--all" ]; then
    tmux list-sessions -F '#{session_name}' 2>/dev/null | while IFS= read -r sess; do
        update_session "$sess"
    done
elif [[ "${1:-}" == *":"* ]]; then
    # Single window target (for Phase 2 hooks)
    session="${1%%:*}"
    update_session "$session"
else
    update_session "${1:?Usage: check-pr-status.sh --all | <session> | <session:window>}"
fi
