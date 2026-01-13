#!/bin/bash

programs=(lsd fd bat dust tokei bandwhich fzf htop lazygit ripgrep neovim httpie sccache tmux curl git cowsay ncdu dua-cli npm go zoxide yazi zsh)
fonts=(font-jetbrains-mono-nerd-font font-iosevka-nerd-font)

if [ -x "$(command -v brew)" ]; then
	brew install ${programs[@]}
	brew install ${fonts[@]}
elif [ -x "$(command -v pacman)" ]; then
	sudo pacman -S --needed ${programs[@]} 2>/dev/null
fi
