alias v="nvim"
alias lg="lazygit"

if hash exa 2>/dev/null; then
    alias ls='exa'
    alias l='exa -l --all --group-directories-first --git'
    alias ll='exa -l --all --all --group-directories-first --git'
    alias lt='exa -T --git-ignore --level=2 --group-directories-first'
    alias llt='exa -lT --git-ignore --level=2 --group-directories-first'
    alias lT='exa -T --git-ignore --level=4 --group-directories-first'
else
    alias l='ls -lah'
    alias ll='ls -alF'
    alias la='ls -A'
fi
