#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGINS_DIR="$SCRIPT_DIR/plugins"

# Install TPM if missing
if [ ! -d "$PLUGINS_DIR/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm "$PLUGINS_DIR/tpm"
fi

# Wipe stale plugins (keep tpm)
[ -d "$PLUGINS_DIR" ] || { echo "Plugins dir not found: $PLUGINS_DIR"; exit 1; }
find "$PLUGINS_DIR" -mindepth 1 -maxdepth 1 ! -name tpm -exec rm -rf {} +

# Fresh install all plugins
"$PLUGINS_DIR/tpm/bin/install_plugins"
