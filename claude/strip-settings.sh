#!/usr/bin/env bash
# Strip machine-specific keys from settings.json → settings.machine.json
# Run before committing settings.json.
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
SETTINGS="$DIR/settings.json"
MACHINE="$DIR/settings.machine.json"

# Keys that are machine-specific
MACHINE_KEYS=("hooks")

if [ ! -f "$SETTINGS" ]; then
  echo "Error: $SETTINGS not found" >&2
  exit 1
fi

# Abort if machine keys are already absent (prevents overwriting machine file with nulls)
has_any=false
for key in "${MACHINE_KEYS[@]}"; do
  if jq -e ".$key" "$SETTINGS" > /dev/null 2>&1; then
    has_any=true
    break
  fi
done
if [ "$has_any" = false ]; then
  echo "Nothing to strip — machine keys already absent from settings.json"
  exit 0
fi

# Build jq filters
extract_parts=()
del_parts=()
for key in "${MACHINE_KEYS[@]}"; do
  extract_parts+=("$key: .$key")
  del_parts+=("del(.$key)")
done

extract_filter="{$(IFS=', '; echo "${extract_parts[*]}")}"
del_filter=$(IFS=' | '; echo "${del_parts[*]}")

# Save machine keys
jq "$extract_filter" "$SETTINGS" > "$MACHINE"

# Remove machine keys from settings
jq "$del_filter" "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"

echo "Stripped machine keys → settings.machine.json"
echo "settings.json is ready to commit"
