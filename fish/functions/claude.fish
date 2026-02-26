function claude --wraps claude
    set -l did_rename 0
    if set -q TMUX
        if test (tmux display-message -p '#{automatic-rename}') = "1"
            set -l dir_name (basename (pwd))
            tmux rename-window "claude|$dir_name"
            set did_rename 1
        end
    end
    command claude $argv
    if test $did_rename = 1
        tmux set-option -w automatic-rename on
    end
end
