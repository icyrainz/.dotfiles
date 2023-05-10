source ~/.config/zsh/aliases.zsh

# Create the extra.zsh file if not exists
[[ -d ~/.config/zsh/extra ]] || touch ~/.config/zsh/extra.zsh
source ~/.config/zsh/extra.zsh

fpath+=~/.config/zsh/completions

[[ -d ~/.antidote ]] ||
    git clone https://github.com/mattmc3/antidote ~/.antidote

[[ -d ~/.tmux/plugins/tpm ]] ||
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

zsh_plugins=~/.config/zsh/zsh_plugins
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  (
    source ~/.antidote/antidote.zsh
    antidote bundle <${zsh_plugins}.txt >${zsh_plugins}.zsh
  )
fi

source ${zsh_plugins}.zsh

eval $(thefuck --alias)
