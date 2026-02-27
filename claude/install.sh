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

echo "Done. Plugins declared in settings.json will activate on next session."
