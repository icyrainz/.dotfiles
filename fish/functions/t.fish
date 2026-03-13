function t -d "Attach to tmux or start a new session"
    tmux attach; or begin
        if set -q TMUX_DEFAULT_DIR
            tmux new-session -s (basename $TMUX_DEFAULT_DIR) -c $TMUX_DEFAULT_DIR
        else
            tmux new-session
        end
    end
end
