ZSH_CONFIG_PATH=~/.config/zsh

source $ZSH_CONFIG_PATH/aliases.zsh
source $ZSH_CONFIG_PATH/keys.zsh

source $ZSH_CONFIG_PATH/plugin_manager.zsh
source $ZSH_CONFIG_PATH/tmux.zsh

# Create the extra.zsh file if not exists
[[ -d $ZSH_CONFIG_PATH/extra ]] || touch $ZSH_CONFIG_PATH/extra.zsh
source $ZSH_CONFIG_PATH/extra.zsh

fpath+=$ZSH_CONFIG_PATH/completions

eval "$(thefuck --alias)"
eval "$(direnv hook zsh)"

# Bat configs
export BAT_THEME="Nord"
