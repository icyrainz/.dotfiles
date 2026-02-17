if type -P lsd >/dev/null 2>&1
    abbr ls lsd
    abbr l 'lsd -l --all --group-directories-first'
    abbr ll 'lsd -l --all --group-directories-first'
    abbr lt 'lsd --tree --depth=2 --group-directories-first'
    abbr llt 'lsd -l --tree --depth=2 --group-directories-first'
    abbr lT 'lsd --tree --depth=4 --group-directories-first'
    abbr la 'lsd --all'
else
    abbr l 'ls -lah'
    abbr ll 'ls -alF'
    abbr la 'ls -A'
end

abbr t 'tmux attach || tmux new-session'
abbr ta 'tmux attach -t'
abbr td 'tmux detach'
abbr ts 'tmux new-session -s'
abbr tc 'tmux choose-session'
abbr tl 'tmux list-sessions'
abbr tka 'tmux kill-server'
abbr tks 'tmux kill-session -t'

abbr yz yazi

abbr v nvim
abbr nv neovide
abbr lg lazygit
abbr lgit lazygit

abbr bk 'cd -'
abbr home 'cd ~'
abbr src 'source ~/.config/fish/config.fish'

abbr zd 'z dotfiles'

abbr cp 'rsync -avzhr --progress'

abbr oc opencode

# Navigation
function ..
    cd ..
end
function ...
    cd ../..
end
function ....
    cd ../../..
end
function ..3
    cd ../../..
end
function .....
    cd ../../../..
end
function ..4
    cd ../../../..
end

abbr dcu 'docker compose up'
abbr dcd 'docker compose down'
abbr dcp 'docker compose pull'

function ssh-tmux
    ssh -t $argv "tmux attach || tmux new"
end
