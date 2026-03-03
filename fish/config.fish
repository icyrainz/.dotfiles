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
fish_add_path "$HOME/.bun/bin"

set -gx BUN_INSTALL "$HOME/.bun"

# Source all .fish files in include folder
for file in $FISH_PATH/include/**/*.fish
    source $file
end

if status is-interactive
    set -l cache_dir ~/.config/fish/.init-cache
    test -d $cache_dir; or mkdir -p $cache_dir

    # Cache shell init scripts — regenerates when binary is updated
    for pair in "fzf:fzf --fish" "zoxide:zoxide init fish" "fnm:fnm env --use-on-cd --shell fish"
        set -l name (string split : $pair)[1]
        set -l cmd (string split -m1 : $pair)[2]
        set -l cache $cache_dir/$name.fish
        set -l bin (command -s $name 2>/dev/null)
        if test -n "$bin"
            if not test -f $cache; or test $bin -nt $cache
                eval $cmd > $cache
            end
            source $cache
        end
    end
end
