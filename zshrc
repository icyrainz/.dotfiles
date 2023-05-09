source ~/.config/zsh/aliases.zsh
source ~/.config/zsh/extra.zsh

fpath+=~/.config/zsh/completions

[[ -d ~/.antidote ]] ||
    git clone https://github.com/mattmc3/antidote ~/.antidote

# source ~/.antidote/antidote.zsh
# antidote load ~/.config/zsh/zsh_plugins.txt

zsh_plugins=~/.config/zsh/zsh_plugins
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  (
    source ~/.antidote/antidote.zsh
    antidote bundle <${zsh_plugins}.txt >${zsh_plugins}.zsh
  )
fi

source ${zsh_plugins}.zsh
