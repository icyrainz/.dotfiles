#!/bin/bash

programs=(exa fd bat fzf dash htop lazygit ripgrep thefuck tree eslint nvim direnv jq)
fonts=(font-code-new-roman-nerd-font font-hack-nerd-font font-agave-nerd-font font-jetbrains-mono-nerd-font)

if [ -x "$(command -v brew)" ]; then
    brew install ${programs[@]}
    brew install ${fonts[@]}
elif [ -x "$(command -v pacman)" ]; then
    sudo pacman -S ${programs[@]}
    sudo pacman -S ${fonts[@]}
fi
