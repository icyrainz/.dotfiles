# Check if Fisher is installed
if not type -q fisher
    # Install Fisher
    curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
end

# List of plugins to install
set plugins jorgebucaran/fisher jethrokuan/z budimanjojo/tmux.fish jethrokuan/fzf ilancosman/tide@v5 jorgebucaran/nvm.fish


# Install plugins
for plugin in $plugins
    fisher install $plugin
end
