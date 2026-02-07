function copybuffer
    if command -q pbcopy
        printf "%s" (commandline) | pbcopy
    else if command -q wl-copy
        printf "%s" (commandline) | wl-copy
    else if command -q xclip
        printf "%s" (commandline) | xclip -selection clipboard
    end
end

bind \co copybuffer
