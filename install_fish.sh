#!/bin/bash

# Check if fish is installed
if ! which fish > /dev/null; then
    # Check if Homebrew is installed
    if ! which brew > /dev/null; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    echo "Installing fish shell..."
    brew install fish
    fish_path=$(which fish)
    echo "Adding fish to the list of allowed shells..."
    echo $fish_path | sudo tee -a /etc/shells
    echo "Changing default shell to fish..."
    sudo chsh -s $fish_path
else
    echo "Fish shell is already installed."
fi
