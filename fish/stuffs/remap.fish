if type -P lsd >/dev/null 2>&1
    abbr ls 'lsd'
    abbr l 'lsd -l --all --group-directories-first'
    abbr ll 'lsd -l --all --group-directories-first'
    abbr lt 'lsd --tree --depth=2 --group-directories-first'
    abbr llt 'lsd -l --tree --depth=2 --group-directories-first'
    abbr lT 'lsd --tree --depth=4 --group-directories-first'
else if type -P exa >/dev/null 2>&1
    abbr ls 'exa'
    abbr l 'exa -l --group-directories-first'
    abbr ll 'exa -l --group-directories-first'
    abbr lt 'exa --tree --level=2 --group-directories-first'
    abbr llt 'exa -l --tree --level=2 --group-directories-first'
    abbr lT 'exa --tree --level=4 --group-directories-first'
else
    abbr l 'ls -lah'
    abbr ll 'ls -alF'
    abbr la 'ls -A'
end

abbr t 'tmux attach || tmux new-session'
abbr tc 'tmux choose-session'
abbr tl 'tmux list-sessions'

abbr v nvim
abbr lg lazygit
abbr lgit lazygit

abbr fi 'fisher install'
abbr fl 'fisher list'
abbr fu 'fisher update'
abbr fr 'fisher remove'

abbr bk 'cd -'
abbr home 'cd ~'
abbr c clear
abbr src 'source ~/.config/fish/config.fish'

abbr zd 'z dotfiles'

# Navigation
function ..    ; cd .. ; end
function ...   ; cd ../.. ; end
function ....  ; cd ../../.. ; end
function ..... ; cd ../../../.. ; end
