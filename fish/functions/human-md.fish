function human-md --description "Push/pull HUMAN.md to/from RustFS"
    set -l dotfiles (realpath ~/.config/fish/config.fish | string replace '/fish/config.fish' '')
    set -l local_path $dotfiles/claude/HUMAN.md
    set -l remote_path rustfs/claude/HUMAN.md

    switch "$argv[1]"
        case push
            mc cp "$local_path" "$remote_path"
        case pull
            mc cp "$remote_path" "$local_path"
        case diff
            set -l tmp (mktemp)
            mc cp "$remote_path" "$tmp" 2>/dev/null
            diff --color "$local_path" "$tmp"
            rm -f "$tmp"
        case ''
            echo "Usage: human-md [push|pull|diff]"
        case '*'
            echo "Unknown command: $argv[1]"
            echo "Usage: human-md [push|pull|diff]"
    end
end
