#!/usr/bin/env bash
file=$(fd -t f | fzf --preview 'bat --color=always {}' \
  --header '  ^a all  ^g default' \
  --bind 'ctrl-a:reload(fd -t f -H --no-ignore)' \
  --bind 'ctrl-g:reload(fd -t f)')

[ -n "$file" ] && nvim "$file"
