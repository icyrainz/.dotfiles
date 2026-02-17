function claude --wraps claude
    if set -q TMUX
        set -l dir_name (basename (pwd))
        tmux rename-window "claude|$dir_name"
    end
    command claude $argv
    if set -q TMUX
        tmux set-option -w automatic-rename on
    end
end
