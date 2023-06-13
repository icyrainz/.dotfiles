function copybuffer
    printf "%s" (commandline) | pbcopy
end

bind \co copybuffer
