#!/bin/bash

programs=(exa lsd fd bat dust procs tealdeer bottom broot skim tokei sd bandwhich fzf dash htop lazygit ripgrep thefuck neovim direnv fish git-delta pgcli httpie hexyl sccache npm tmux openvpn nmap terminal-notifier helix coreutils curl git asdf)
programs_brew_only=(mprocs fnm)
fonts=(font-hack-nerd-font font-agave-nerd-font font-jetbrains-mono-nerd-font)

if [ -x "$(command -v brew)" ]; then
    brew install ${programs[@]}
    brew install ${programs_brew_only[@]}
    brew install ${fonts[@]}
elif [ -x "$(command -v pacman)" ]; then
    sudo pacman -S --needed ${programs[@]} 2>/dev/null
fi
