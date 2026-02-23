#!/usr/bin/env bash
# Interactive ripgrep → nvim at line
# Type to search, add " -- <glob>" to filter files
# Examples:
#   myFunction              → search all files
#   myFunction -- *.ts      → search only .ts files
#   myFunction -- !*.test.* → exclude test files
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

file=$(
  fzf --ansi --disabled --query "" \
    --prompt "rg> " \
    --header "  Type to search. Add ' -- *.ext' to filter by glob" \
    --bind "start:reload:bash $SCRIPT_DIR/rg-query.sh {q}" \
    --bind "change:reload:sleep 0.1; bash $SCRIPT_DIR/rg-query.sh {q}" \
    --delimiter : \
    --preview 'bat --color=always --highlight-line {2} {1}' \
    --preview-window '+{2}-5'
)

[ -z "$file" ] && exit 0

nvim "$(echo "$file" | awk -F: '{print "+"$2, $1}')"
