#!/bin/bash

programs=(lsd fd bat dust procs tealdeer bottom broot skim tokei sd bandwhich fzf dash htop lazygit ripgrep thefuck neovim direnv fish git-delta pgcli httpie hexyl sccache npm tmux openvpn nmap terminal-notifier coreutils curl git kondo nushell)
programs_brew_only=(mprocs)
fonts=(font-jetbrains-mono-nerd-font font-iosevka-nerd-font)

if [ -x "$(command -v brew)" ]; then
	brew install ${programs[@]}
	brew install ${programs_brew_only[@]}
	brew install ${fonts[@]}
elif [ -x "$(command -v pacman)" ]; then
	sudo pacman -S --needed ${programs[@]} 2>/dev/null
fi
