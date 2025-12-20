#!/bin/bash
# lxc-bootstrap.sh
# Usage: curl -sL https://raw.githubusercontent.com/icyrainz/.dotfiles/master/lxc-bootstrap.sh | bash

set -e

echo "==> Installing packages..."
apt update && apt install -y \
  tmux \
  ripgrep \
  fzf \
  htop \
  bat \
  neovim

echo "==> Setting up tmux..."
cat >~/.tmux.conf <<'TMUXCONF'
# Options
set -g default-terminal "tmux-256color"
set -g mouse on
set -g history-limit 100000
set -g base-index 1
set -g pane-base-index 1
set -g renumber-windows on
set -g escape-time 0
setw -g mode-keys vi

# Prefix: C-Space
unbind C-b
set -g prefix C-Space
bind C-Space send-prefix

# Reload config
bind r source-file ~/.tmux.conf \; display "Reloaded"

# Splits
unbind %
bind '\' split-window -h -c "#{pane_current_path}"
bind '-' split-window -v -c "#{pane_current_path}"

# Pane navigation (prefix + hjkl)
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Resize
bind -n M-Left resize-pane -L 5
bind -n M-Down resize-pane -D 2
bind -n M-Up resize-pane -U 2
bind -n M-Right resize-pane -R 5

# Vi copy mode
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi y send-keys -X copy-selection

# Kill
bind X kill-pane
bind W kill-window
TMUXCONF

echo "==> Setting up bash..."
cat >>~/.bashrc <<'BASHRC'

# --- Custom ---
alias c='clear'
alias q='exit'
alias ..='cd ..'
alias ...='cd ../..'

alias v='nvim'
export EDITOR=nvim

alias rg='rg --smart-case'
alias t='tmux attach || tmux new-session'
alias bat='batcat'

alias d='docker'
alias dc='docker compose'
alias dcup='docker compose pull && docker compose down && docker compose up -d'
alias dcre='docker compose down && docker compose up -d'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dlogs='docker logs -f'
BASHRC

echo "==> Done! Run: source ~/.bashrc"
