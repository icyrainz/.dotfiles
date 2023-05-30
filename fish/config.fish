fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin
set fish_greeting

set -gx FISH_PATH ~/.config/fish

abbr sourceconfig "source $FISH_PATH/config.fish"
abbr v nvim
abbr lg lazygit
abbr lgit lazygit

set -gx USE_AI_TOOLS false

if test -e $FISH_PATH/extra.fish
    source $FISH_PATH/extra.fish
end

# thefuck --alias | source
direnv hook fish | source

# # fnm
# fish_add_path "/Users/tuephan/Library/Application Support/fnm"
# fnm env | source

# tmux settings
set -Ux fish_tmux_autostart false
set -Ux fish_tmux_autostart_once false

# Auto switch node using nvm
function __nvm_auto --on-variable PWD
    if test -e .nvmrc
        set nvmrc_version (cat .nvmrc)
        set current_version (nvm current)

        if test $nvmrc_version != $current_version
            nvm use 2>/dev/null
        end
    end
end
__nvm_auto

# Source all .fish files in stuffs folder
for file in $FISH_PATH/stuffs/*.fish
    source $file
end

set -gx RUSTC_WRAPPER /opt/homebrew/bin/sccache

if status is-interactive
    # Commands to run in interactive sessions can go here
end

