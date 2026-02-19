#!/bin/bash

# Tools used in shell configs (fish, zsh, bash) or universally useful
programs=(
  bat
  btop
  curl
  dust
  fd
  fish
  fzf
  gh
  git
  htop
  jq
  lazygit
  lsd
  neovim
  ripgrep
  sccache
  sesh
  tmux
  tree
  wget
  worktrunk
  yazi
  zoxide
  zsh
  cowsay
  fortune
)

fonts=(font-jetbrains-mono-nerd-font)

if [ -x "$(command -v brew)" ]; then
  brew install "${programs[@]}"
  brew install "${fonts[@]}"

elif [ -x "$(command -v pacman)" ]; then
  arch_pkgs=(
    bat btop curl dust fd fish fzf github-cli git htop jq
    lazygit lsd neovim ripgrep sccache sesh tmux tree wget
    yazi zoxide zsh worktrunk
    cowsay fortune-mod
  )
  sudo pacman -S --needed "${arch_pkgs[@]}"
  echo ""
  echo "Install nerd fonts from AUR: ttf-jetbrains-mono-nerd"

elif [ -x "$(command -v apt-get)" ]; then
  # Install what's available from default repos
  sudo apt-get update
  sudo apt-get install -y \
    bat btop curl fd-find fish fzf git htop jq \
    neovim ripgrep tmux tree wget zoxide zsh \
    cowsay fortune-mod

  # Debian/Ubuntu renames bat -> batcat, fd -> fdfind
  [ -x "$(command -v batcat)" ] && sudo ln -sf "$(command -v batcat)" /usr/local/bin/bat
  [ -x "$(command -v fdfind)" ] && sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd

  echo ""
  echo "Some tools need manual installation on Debian/Ubuntu:"
  echo "  gh:       https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
  echo "  lazygit:  https://github.com/jesseduffield/lazygit#ubuntu"
  echo "  yazi:     https://github.com/sxyazi/yazi#installation"
  echo "  zoxide:   curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash"
  echo "  sesh:     https://github.com/joshmedeski/sesh#installation"
  echo "  worktrunk: cargo install worktrunk"
  echo "  Others:   cargo install lsd dust sccache"
fi
