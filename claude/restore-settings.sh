#!/usr/bin/env bash
# Restore machine-specific keys from settings.machine.json back into settings.json.
# Run after committing settings.json.
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
SETTINGS="$DIR/settings.json"
MACHINE="$DIR/settings.machine.json"

if [ ! -f "$MACHINE" ]; then
  echo "No settings.machine.json found, nothing to restore"
  exit 0
fi

if [ ! -f "$SETTINGS" ]; then
  echo "Error: $SETTINGS not found" >&2
  exit 1
fi

# Merge machine keys back
jq -s '.[0] * .[1]' "$SETTINGS" "$MACHINE" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"

echo "Restored machine keys into settings.json"
