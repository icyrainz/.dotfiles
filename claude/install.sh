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
  obra/superpowers-marketplace
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

# --- Symlink shared skills ---
# Dotbot can't handle two glob entries for the same target dir (YAML duplicate keys),
# so we link claude/skills/* here instead.
SKILLS_DIR="$HOME/.claude/skills"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$SKILLS_DIR"
for skill in "$SCRIPT_DIR"/skills/*/; do
  name="$(basename "$skill")"
  target="$SKILLS_DIR/$name"
  if [ -L "$target" ] || [ -e "$target" ]; then
    continue
  fi
  ln -s "$skill" "$target"
  echo "Linked skill: $name"
done

# --- Symlink homelab skills (gated by marker) ---
if [ -f "$HOME/.akio-homelab" ]; then
  for skill in "$SCRIPT_DIR"/skills-homelab/*/; do
    [ -d "$skill" ] || continue
    name="$(basename "$skill")"
    target="$SKILLS_DIR/$name"
    if [ -L "$target" ] || [ -e "$target" ]; then
      continue
    fi
    ln -s "$skill" "$target"
    echo "Linked homelab skill: $name"
  done
else
  echo "Skipping homelab skills (~/.akio-homelab not found)"
fi

echo "Done. Plugins declared in settings.json will activate on next session."
