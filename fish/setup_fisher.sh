#!/bin/bash

# Check if Fisher is installed
if ! fish -c 'type -q fisher' >/dev/null
then
    # Install Fisher
    fish -c 'curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher'
fi
