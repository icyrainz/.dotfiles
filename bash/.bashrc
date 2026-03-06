export PATH="$HOME/.local/bin:$PATH"

# Source custom bash configuration
if [ -f ~/.bash_custom ]; then
  source ~/.bash_custom
fi

# fnm
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --use-on-cd)"
fi

# zoxide integration (smarter cd)
command -v zoxide &>/dev/null && eval "$(zoxide init bash)"

# bun
if [ -d "$HOME/.bun" ]; then
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
fi
