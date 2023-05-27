fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin
set fish_greeting

set -gx FISH_PATH ~/.config/fish

abbr sourceconfig "source $FISH_PATH/config.fish"
abbr v nvim
abbr lg lazygit

set -gx USE_AI_TOOLS false

if test -e $FISH_PATH/extra.fish
    source $FISH_PATH/extra.fish
end

if status is-interactive
    # Commands to run in interactive sessions can go here
    cd $HOME
end

