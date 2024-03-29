function __check_nvm --on-variable PWD --description 'Do nvm stuff'
    if test -f .nvmrc
        set node_version (node -v)
        set node_version_target (cat .nvmrc)
        set nvmrc_node_version (nvm list | grep $node_version_target)

        if string match -q -- "*$node_version" $nvmrc_node_version
            # already current node version
        else if not set -q $nvmrc_node_version
            # install
            nvm install $node_version_target
        else
            nvm use $node_version_target
        end
    end
end

if type -q nvm
    and status is-interactive
    __check_nvm
end
