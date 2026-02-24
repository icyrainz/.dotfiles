#!/usr/bin/env bash
set -euo pipefail

command -v fish >/dev/null || exit 0

fish -c '
  # Install Fisher if missing
  if not type -q fisher
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
    fisher install jorgebucaran/fisher
  end

  # Fresh install all plugins from fish_plugins
  fisher update
'
