#!/usr/bin/env bash
# wt-session - worktrunk + tmux window integration
# Run inside tmux popup to pick a worktree and open in new window

DIRECTIVE=$(mktemp)
WORKTRUNK_DIRECTIVE_FILE="$DIRECTIVE" /opt/homebrew/bin/wt switch --branches
EXIT=$?

if [ $EXIT -ne 0 ] || [ ! -s "$DIRECTIVE" ]; then
  rm -f "$DIRECTIVE"
  exit $EXIT
fi

# Parse worktree path from directive (cd '/path/to/worktree')
WORKTREE_PATH=$(grep '^cd ' "$DIRECTIVE" | head -1 | sed "s/^cd //; s/^'//; s/'$//; s/^\"//" | sed 's/"$//')
rm -f "$DIRECTIVE"

[ -z "$WORKTREE_PATH" ] && exit 0

# Get branch name
BRANCH=$(git -C "$WORKTREE_PATH" branch --show-current 2>/dev/null)
[ -z "$BRANCH" ] && BRANCH=$(basename "$WORKTREE_PATH")

# Create tmux window at worktree, named after branch
tmux new-window -c "$WORKTREE_PATH" -n "$BRANCH"
