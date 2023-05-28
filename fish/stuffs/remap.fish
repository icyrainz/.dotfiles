if type -P lsd >/dev/null 2>&1
    alias ls 'lsd'
    alias l 'lsd -l --all --group-directories-first'
    alias ll 'lsd -l --all --group-directories-first'
    alias lt 'lsd --tree --depth=2 --group-directories-first'
    alias llt 'lsd -l --tree --depth=2 --group-directories-first'
    alias lT 'lsd --tree --depth=4 --group-directories-first'
else if type -P exa >/dev/null 2>&1
    alias ls 'exa'
    alias l 'exa -l --group-directories-first'
    alias ll 'exa -l --group-directories-first'
    alias lt 'exa --tree --level=2 --group-directories-first'
    alias llt 'exa -l --tree --level=2 --group-directories-first'
    alias lT 'exa --tree --level=4 --group-directories-first'
else
    alias l 'ls -lah'
    alias ll 'ls -alF'
    alias la 'ls -A'
end
