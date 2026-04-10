#!/usr/bin/env bash
# Helper for the dotenv tv channel actions
set -euo pipefail

ENV_FILE=".env"

update_env() {
  local key="$1" val="$2"
  if grep -q "^${key}=" "$ENV_FILE" 2>/dev/null; then
    awk -v key="$key" -v val="$val" \
      'index($0, key "=") == 1 { print key "=" val; next } { print }' \
      "$ENV_FILE" > "${ENV_FILE}.tmp" && mv "${ENV_FILE}.tmp" "$ENV_FILE"
  else
    echo "${key}=${val}" >> "$ENV_FILE"
  fi
}

case "$1" in
  paste)
    update_env "$2" "$(pbpaste 2>/dev/null)"
    ;;
  edit)
    tmpfile=$(mktemp /tmp/env-edit-XXXXXX)
    echo "${3:-}" > "$tmpfile"
    nvim "$tmpfile"
    update_env "$2" "$(cat "$tmpfile")"
    rm -f "$tmpfile"
    ;;
  new)
    touch "$ENV_FILE"
    tmpfile=$(mktemp /tmp/env-new-XXXXXX)
    echo "KEY=value" > "$tmpfile"
    nvim "$tmpfile"
    while IFS= read -r line; do
      line=$(sed 's/^[[:space:]]*//' <<< "$line")
      [[ -z "$line" || "$line" == \#* ]] && continue
      key="${line%%=*}"
      val="${line#*=}"
      [[ -z "$key" || "$key" == "$line" ]] && continue
      update_env "$key" "$val"
    done < "$tmpfile"
    rm -f "$tmpfile"
    ;;
esac
