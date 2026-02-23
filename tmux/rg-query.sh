#!/usr/bin/env bash
# Helper for rg-edit.sh: parse "pattern -- glob" syntax
input="$*"
pattern="${input%% -- *}"
glob=""
if [[ "$input" == *" -- "* ]]; then
  glob="${input#* -- }"
fi
[ -z "$pattern" ] && exit 0
if [ -n "$glob" ]; then
  rg --column --line-number --no-heading --color=always --smart-case --glob "$glob" "$pattern" || true
else
  rg --column --line-number --no-heading --color=always --smart-case "$pattern" || true
fi
