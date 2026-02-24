#!/usr/bin/env bash
# Ensure the active (or default) peon-ping sound pack is installed

command -v peon >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

config="$(dirname "$0")/config.json"
[ -f "$config" ] || exit 0

pack="$(jq -r '.active_pack // .default_pack // empty' "$config")"
[ -n "$pack" ] && peon packs install "$pack"
