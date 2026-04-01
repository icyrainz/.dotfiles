#!/bin/bash
# Set window indicator to "done"
[ -n "$TMUX" ] && tmux set-option -w @claude-state " ■"
