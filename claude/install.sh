#!/usr/bin/env bash
# Bootstrap Claude Code: install the CLI, register marketplaces, enable plugins.
set -euo pipefail

# --- Install Claude Code CLI ---
if ! command -v claude &>/dev/null; then
  echo "Installing Claude Code…"
  curl -fsSL https://claude.ai/install.sh | bash
else
  echo "Claude Code already installed"
fi

# --- Register third-party marketplaces ---
MARKETPLACES=(
)

for repo in "${MARKETPLACES[@]}"; do
  slug="${repo##*/}"
  if [ -d "$HOME/.claude/plugins/marketplaces/$slug" ]; then
    echo "Marketplace $slug already registered"
  else
    echo "Adding marketplace $slug…"
    claude plugin marketplace add "$repo" || echo "!! Failed to add $slug"
  fi
done

# --- Update all marketplaces ---
echo "Updating marketplaces…"
claude plugin marketplace update || true

# --- Symlink skills ---
# Dotbot can't handle multiple glob entries for the same target dir (YAML duplicate keys),
# so we link skills/* and skills-homelab/* here instead.
SKILLS_DIR="$HOME/.claude/skills"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$SKILLS_DIR"

link_skills() {
  local label="$1" dir="$2"
  local count=0 linked=0
  for skill in "$dir"/*/; do
    [ -d "$skill" ] || continue
    name="$(basename "$skill")"
    target="$SKILLS_DIR/$name"
    count=$((count + 1))
    if [ -L "$target" ] || [ -e "$target" ]; then
      continue
    fi
    ln -s "$skill" "$target"
    linked=$((linked + 1))
    echo "  Linked: $name"
  done
  if [ "$linked" -eq 0 ]; then
    echo "  All $count skills already linked"
  else
    echo "  Linked $linked/$count skills"
  fi
}

echo "Linking global skills..."
link_skills "global" "$SCRIPT_DIR/skills"

if [ -f "$HOME/.akio-personal" ]; then
  echo "Linking personal skills..."
  link_skills "personal" "$SCRIPT_DIR/skills-personal"
else
  echo "Skipping personal skills (~/.akio-personal not found)"
fi

if [ -f "$HOME/.akio-homelab" ]; then
  echo "Linking homelab skills..."
  link_skills "homelab" "$SCRIPT_DIR/skills-homelab"
else
  echo "Skipping homelab skills (~/.akio-homelab not found)"
fi

echo "Done. Plugins declared in settings.json will activate on next session."
