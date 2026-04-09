#!/usr/bin/env bash
recipe=$(just --list --unsorted 2>/dev/null | tail -n +2 | sed 's/^[[:space:]]*//' | \
  fzf --layout=reverse \
    --header 'justfile recipes' \
    --preview 'just --show {1} 2>/dev/null' \
    --preview-window=down:4:wrap | awk '{print $1}')

[ -n "$recipe" ] && just "$recipe"
