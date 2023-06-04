# # fnm
# fish_add_path "/Users/tuephan/Library/Application Support/fnm"
# fnm env | source

# Auto switch node using nvm
function __nvm_auto --on-variable PWD
    if test -e .nvmrc
        set nvmrc_version (cat .nvmrc)
        set current_version (nvm current)

        if test $nvmrc_version != $current_version
            nvm use
        end
    end
end
__nvm_auto
