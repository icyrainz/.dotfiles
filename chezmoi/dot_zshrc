# --- Zsh Configuration ---

# Path configuration
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# Editor
export EDITOR=nvim
export VISUAL=nvim

# Tool configurations
export BAT_THEME=1337

# --- Basic Settings ---
setopt AUTO_CD              # cd by just typing directory name
setopt HIST_IGNORE_DUPS     # Don't save duplicate commands in history
setopt HIST_FIND_NO_DUPS    # Don't show duplicates when searching
setopt SHARE_HISTORY        # Share history between sessions
setopt APPEND_HISTORY       # Append to history file
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# --- Completions ---
autoload -Uz compinit
compinit

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# --- Basic Aliases ---
alias c='clear'
alias q='exit'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Modern CLI tools
alias ls='lsd'
alias l='lsd -l --all --group-directories-first'
alias ll='lsd -l --all --group-directories-first'
alias lt='lsd --tree --depth=2 --group-directories-first'
alias llt='lsd -l --tree --depth=2 --group-directories-first'
alias lT='lsd --tree --depth=4 --group-directories-first'
alias la='lsd --all'

alias cat='bat'
alias v='nvim'
alias vim='nvim'

# Navigation helpers
alias bk='cd -'
alias home='cd ~'

# ripgrep smart case by default
alias rg='rg --smart-case'

# --- Tmux Aliases ---
alias t='tmux attach || tmux new-session'
alias ta='tmux attach -t'
alias td='tmux detach'
alias ts='tmux new-session -s'
alias tc='tmux choose-session'
alias tl='tmux list-sessions'
alias tka='tmux kill-server'
alias tks='tmux kill-session -t'

# SSH with tmux
ssh-tmux() {
    ssh -t "$@" "tmux attach || tmux new"
}

# Quick SSH shortcuts
alias ssh-lab='ssh -t root@akio-lab "tmux attach || tmux new"'

# --- Docker Aliases ---
alias d='docker'
alias dc='docker compose'
alias dcu='docker compose up'
alias dcd='docker compose down'
alias dcp='docker compose pull'
alias dcup='docker compose pull && docker compose down && docker compose up -d'
alias dcre='docker compose down && docker compose up -d'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dlogs='docker logs -f'

# --- Git Aliases ---
alias g='git'
alias gs='git status'
alias gd='git diff'
alias gp='git push'
alias gl='git pull'
alias lg='lazygit'

# --- File Manager ---
alias yz='yazi'

# --- rsync with progress ---
alias cp='rsync -avzhr --progress'

# --- Integrations ---

# fzf integration (Ctrl+R for history, Ctrl+T for files, Alt+C for cd)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# zoxide integration (smarter cd)
eval "$(zoxide init zsh)"

# --- Key Bindings ---
# Set these AFTER fzf integration to prevent overrides
bindkey -e  # Enable emacs mode
bindkey '^P' up-line-or-history      # Ctrl+P for previous command
bindkey '^N' down-line-or-history    # Ctrl+N for next command

# --- Prompt ---
# Simple two-line prompt with current directory and git branch
autoload -Uz vcs_info
precmd() { vcs_info }
setopt PROMPT_SUBST

zstyle ':vcs_info:git:*' formats ' (%b)'
zstyle ':vcs_info:*' enable git

PROMPT='%F{cyan}%~%f%F{yellow}${vcs_info_msg_0_}%f
%F{green}❯%f '
