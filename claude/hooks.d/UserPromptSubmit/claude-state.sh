#!/bin/bash
# Set window indicator to "running"
[ -n "$TMUX" ] && tmux set-option -w @claude-state " ▶"
