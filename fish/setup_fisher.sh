#!/bin/bash

# Check if Fisher is installed
if ! fish -c 'type -q fisher' >/dev/null
then
    # Install Fisher
    fish -c 'curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher'
fi

# List of plugins to install
plugins=("jorgebucaran/fisher" "jethrokuan/fzf" "ilancosman/tide@v5" "jorgebucaran/nvm.fish")

# Install plugins
for plugin in "${plugins[@]}"
do
    fish -c "fisher install $plugin"
done
