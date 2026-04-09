#!/usr/bin/env bash
# Update external skills from GitHub repos into ~/.claude/skills/
# Reads repo list from external-skills-repos.yml

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPOS_FILE="$SCRIPT_DIR/external-skills-repos.yml"
DEST_DIR="${HOME}/.claude/skills"

mkdir -p "$DEST_DIR"

# Parse YAML: extract name, url, and optional skills list
name="" url="" skills=()
sync_current() {
    [[ -z "$name" || -z "$url" ]] && return
    local clone_dir="/tmp/claude-skills-$name"
    echo "[$name] Syncing from $url"
    if [ -d "$clone_dir" ] && git -C "$clone_dir" rev-parse --git-dir &>/dev/null; then
        git -C "$clone_dir" pull --ff-only
    else
        rm -rf "$clone_dir"
        git clone --depth 1 --filter=blob:none --sparse "$url" "$clone_dir"
        git -C "$clone_dir" sparse-checkout set skills
    fi
    if [ ${#skills[@]} -eq 0 ]; then
        # No filter — copy all skills
        cp -r "$clone_dir/skills/"* "$DEST_DIR/"
    else
        for skill in "${skills[@]}"; do
            if [ -d "$clone_dir/skills/$skill" ]; then
                cp -r "$clone_dir/skills/$skill" "$DEST_DIR/"
            else
                echo "  WARNING: skill '$skill' not found in $name"
            fi
        done
    fi
    echo "[$name] Done (${#skills[@]:-all} skills)."
}

while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ ^-\ *name:\ *(.+) ]]; then
        sync_current
        name="${BASH_REMATCH[1]}" url="" skills=()
    elif [[ "$line" =~ ^\ +url:\ *(.+) ]]; then
        url="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^[[:space:]]+-[[:space:]]+(.+) ]]; then
        skills+=("${BASH_REMATCH[1]}")
    fi
done < "$REPOS_FILE"
sync_current

echo "All skills synced to $DEST_DIR"
