#!/bin/zsh

[[ -d ~/.antidote ]] ||
    git clone https://github.com/mattmc3/antidote ~/.antidote

# Install Antidote
chmod +x ~/.antidote/antidote
~/.antidote/antidote update
