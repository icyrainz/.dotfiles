#!/bin/bash
# Clear window indicator when session ends
[ -n "$TMUX" ] && tmux set-option -wu @claude-state
