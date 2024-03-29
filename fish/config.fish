set -u fish_greeting ""

set -gx EDITOR nvim
set -gx USE_AI_TOOLS false
set -gx FISH_PATH ~/.config/fish

set -gx RUSTC_WRAPPER /opt/homebrew/bin/sccache
set -gx ERL_AFLAGS "-kernel shell_history enabled"

set -gx BAT_THEME 1337
set -gx NEOVIDE_FRAME transparent
set -gx NEOVIDE_TITLE_HIDDEN 1

fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin
fish_add_path "$HOME/.cargo/bin"
fish_add_path "$HOME/.local/share/nvim/mason/bin"

# Source all .fish files in include folder
for file in $FISH_PATH/include/**/*.fish
    source $file
end

if status is-interactive
    # Commands to run in interactive sessions can go here
    zoxide init fish | source
end

direnv hook fish | source
