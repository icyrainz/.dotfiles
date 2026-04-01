#!/bin/bash
# Set window indicator to "needs input"
[ -n "$TMUX" ] && tmux set-option -w @claude-state " ●"
