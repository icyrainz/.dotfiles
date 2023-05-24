#!/bin/bash

programs=(exa lsd fd bat dust procs tealdeer bottom broot skim tokei sd bandwhich fzf dash htop lazygit ripgrep thefuck eslint nvim direnv jq)
fonts=(font-code-new-roman-nerd-font font-hack-nerd-font font-agave-nerd-font font-jetbrains-mono-nerd-font)

if [ -x "$(command -v brew)" ]; then
    brew install ${programs[@]}
    brew install ${fonts[@]}
elif [ -x "$(command -v pacman)" ]; then
    sudo pacman -S ${programs[@]}
    sudo pacman -S ${fonts[@]}
fi
