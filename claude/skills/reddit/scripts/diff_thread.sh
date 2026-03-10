#!/usr/bin/env bash
# Compares two Reddit thread fetches and outputs only meaningful changes.
# Usage: diff_thread.sh <url> <baseline_file>
#
# Fetches the thread, compares against baseline, outputs:
# - New comments (not in baseline)
# - Significant score changes (post or comments)
# - New comment count
# Overwrites baseline with new data after comparison.

set -euo pipefail

URL="${1:?Usage: diff_thread.sh <url> <baseline_file>}"
BASELINE="${2:?Usage: diff_thread.sh <url> <baseline_file>}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

CLEAN_URL=$(echo "$URL" | sed 's|/$||; s|?.*||; s|\.json$||')
JSON_URL="${CLEAN_URL}.json"

NEW_JSON=$(curl -sS -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
  --max-time 15 "$JSON_URL" 2>/dev/null)

if [ -z "$NEW_JSON" ]; then
  echo "ERROR: Failed to fetch thread" >&2
  exit 1
fi

# If no baseline exists yet, create it and exit
if [ ! -f "$BASELINE" ]; then
  echo "$NEW_JSON" > "$BASELINE"
  echo "BASELINE_CREATED"
  exit 0
fi

OLD_JSON=$(cat "$BASELINE")

python3 "$SCRIPT_DIR/diff_compare.py" "$OLD_JSON" "$NEW_JSON"

# Update baseline
echo "$NEW_JSON" > "$BASELINE"
