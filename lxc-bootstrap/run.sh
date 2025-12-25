#!/bin/bash
# lxc-bootstrap/run.sh
# Usage: curl -sL https://raw.githubusercontent.com/icyrainz/.dotfiles/master/lxc-bootstrap/run.sh | bash

set -e

REPO_BASE="https://raw.githubusercontent.com/icyrainz/.dotfiles/master/lxc-bootstrap"

echo "==> Installing packages..."
apt update && apt install -y \
  git \
  tmux \
  ripgrep \
  htop \
  btop \
  atop \
  bat \
  lnav \
  neovim

echo "==> Installing lazydocker..."
curl -sL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
echo "Installed lazydocker to ~/.local/bin/lazydocker"

echo "==> Installing fzf..."
FZF_VERSION=$(curl -s https://api.github.com/repos/junegunn/fzf/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
if [ ! -d ~/.fzf ]; then
  git clone --depth 1 --branch "$FZF_VERSION" https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --bin --no-update-rc
  cp ~/.fzf/bin/fzf /usr/local/bin/fzf
  echo "Installed fzf $FZF_VERSION to /usr/local/bin/fzf"
else
  cd ~/.fzf && git fetch --tags && git checkout "$FZF_VERSION" && ./install --bin --no-update-rc
  cp ~/.fzf/bin/fzf /usr/local/bin/fzf
  echo "Updated fzf to $FZF_VERSION (idempotent)"
fi

echo "==> Setting up tmux..."
curl -sL "${REPO_BASE}/tmux.conf" -o ~/.tmux.conf
echo "Installed tmux config to ~/.tmux.conf"

echo "==> Setting up bash..."
curl -sL "${REPO_BASE}/bash_custom" -o ~/.bash_custom
echo "Installed bash custom config to ~/.bash_custom"

# Check if .bashrc already sources bash_custom (idempotent check)
if ! grep -q "source.*\.bash_custom" ~/.bashrc 2>/dev/null; then
  echo "" >>~/.bashrc
  echo "# Source custom bash configuration" >>~/.bashrc
  echo "if [ -f ~/.bash_custom ]; then" >>~/.bashrc
  echo "  source ~/.bash_custom" >>~/.bashrc
  echo "fi" >>~/.bashrc
  echo "Added source line to ~/.bashrc"
else
  echo "~/.bashrc already sources ~/.bash_custom (idempotent)"
fi

echo ""
echo "==> Done! Run: source ~/.bashrc"
