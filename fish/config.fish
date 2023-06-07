set -u fish_greeting ""

set -gx EDITOR nvim
set -gx USE_AI_TOOLS false
set -gx FISH_PATH ~/.config/fish

set -gx RUSTC_WRAPPER /opt/homebrew/bin/sccache

set -gx BAT_THEME "1337"

fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin
fish_add_path "$HOME/.cargo/bin"
fish_add_path "$HOME/.local/share/nvim/mason/bin"

if test -e $FISH_PATH/extra.fish
    source $FISH_PATH/extra.fish
end

# Source all .fish files in stuffs folder
for file in $FISH_PATH/stuffs/*.fish
    source $file
end

if status is-interactive
    # Commands to run in interactive sessions can go here
    zoxide init fish | source
    thefuck --alias | source
    direnv hook fish | source

    # auto-switch node version via nvm.fish
    function __nvm_auto --on-variable PWD
        nvm use --silent 2>/dev/null
    end
    __nvm_auto
end

source /opt/homebrew/opt/asdf/libexec/asdf.fish
