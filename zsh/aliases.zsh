alias v="nvim"
alias lg="lazygit"

if hash lsd 2>/dev/null; then
    alias ls='lsd'
    alias l='lsd -l --all --group-directories-first'
    alias ll='lsd -l --all --group-directories-first'
    alias lt='lsd --tree --depth=2 --group-directories-first'
    alias llt='lsd -l --tree --depth=2 --group-directories-first'
    alias lT='lsd --tree --depth=4 --group-directories-first'
else
    alias l='ls -lah'
    alias ll='ls -alF'
    alias la='ls -A'
fi
