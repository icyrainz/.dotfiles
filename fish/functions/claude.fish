function claude --wraps claude
    if set -q TMUX
        set -l current_name (tmux display-message -p '#{automatic-rename}')
        if test "$current_name" = "1"
            set -l dir_name (basename (pwd))
            tmux rename-window "claude|$dir_name"
        end
    end
    command claude $argv
    if set -q TMUX
        tmux set-option -w automatic-rename on
    end
end
