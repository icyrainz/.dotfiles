set -u fish_greeting ""

set -gx EDITOR nvim
set -gx USE_AI_TOOLS false
set -gx FISH_PATH ~/.config/fish

set -gx ERL_AFLAGS "-kernel shell_history enabled"

set -gx BAT_THEME 1337

# macOS (Homebrew)
if test -d /opt/homebrew
    fish_add_path /opt/homebrew/bin
    fish_add_path /opt/homebrew/sbin
    command -q sccache; and set -gx RUSTC_WRAPPER (command -s sccache)
end

fish_add_path "$HOME/.cargo/bin"
fish_add_path "$HOME/.local/share/nvim/mason/bin"
fish_add_path "$HOME/.local/bin"

# Source all .fish files in include folder
for file in $FISH_PATH/include/**/*.fish
    source $file
end

if status is-interactive
    # Commands to run in interactive sessions can go here
    zoxide init fish | source

    # Auto-switch node version when entering a directory with .nvmrc
    function _nvm_auto --on-variable PWD
        test -f .nvmrc; or test -f .node-version; or return
        nvm use 2>/dev/null
    end
end
