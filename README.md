# Dotfiles

Personal dotfiles managed with **chezmoi**.

## What's Included

| Config | Description |
|--------|-------------|
| zsh | Shell config with aliases, zoxide, fzf |
| nvim | Neovim with LazyVim |
| wezterm | Terminal emulator |
| tmux | Terminal multiplexer |
| sway | Window manager (Arch Linux only) |

## Required CLI Tools

```bash
# Ubuntu/Pop!_OS
sudo apt install -y zsh neovim fzf ripgrep bat lsd cowsay fortune-mod

# zoxide
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit lazygit.tar.gz

# Fix bat alias (Ubuntu names it batcat)
sudo ln -sf /usr/bin/batcat /usr/local/bin/bat
```

```bash
# Arch Linux
pacman -S zsh neovim fzf ripgrep bat lsd zoxide lazygit cowsay fortune-mod
```

```bash
# macOS
brew install zsh neovim fzf ripgrep bat lsd zoxide lazygit cowsay fortune
```

## Install

### Pop!_OS / Ubuntu

```bash
# Clone the repo
git clone https://github.com/icyrainz/.dotfiles.git ~/repo/.dotfiles

# Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin

# Configure chezmoi source directory
mkdir -p ~/.config/chezmoi
echo 'sourceDir = "~/repo/.dotfiles/chezmoi"' > ~/.config/chezmoi/chezmoi.toml

# Preview and apply
chezmoi diff
chezmoi apply

# Set zsh as default shell
chsh -s $(which zsh)
```

### Arch Linux

```bash
# Clone the repo
git clone https://github.com/icyrainz/.dotfiles.git ~/repo/.dotfiles

# Install chezmoi
pacman -S chezmoi

# Configure chezmoi source directory
mkdir -p ~/.config/chezmoi
echo 'sourceDir = "~/repo/.dotfiles/chezmoi"' > ~/.config/chezmoi/chezmoi.toml

# Preview and apply
chezmoi diff
chezmoi apply

# Set zsh as default shell
chsh -s $(which zsh)
```

### macOS

```bash
# Clone the repo
git clone https://github.com/icyrainz/.dotfiles.git ~/repo/.dotfiles

# Install chezmoi
brew install chezmoi

# Configure chezmoi source directory
mkdir -p ~/.config/chezmoi
echo 'sourceDir = "~/repo/.dotfiles/chezmoi"' > ~/.config/chezmoi/chezmoi.toml

# Preview and apply
chezmoi diff
chezmoi apply

# Set zsh as default shell
chsh -s $(which zsh)
```

## OS-Specific Configs

The `.chezmoiignore` file handles OS-specific exclusions:
- **sway**: Only applied on Arch Linux (excluded on Pop!_OS/Ubuntu which use COSMIC/GNOME)

## Usage

```bash
# Apply changes from dotfiles to system
chezmoi apply

# See what would change
chezmoi diff

# Edit a managed file
chezmoi edit ~/.zshrc

# Add a new file to chezmoi
chezmoi add ~/.config/some/config

# Pull latest and apply
chezmoi update
```

## Legacy

This repo previously used **dotbot** for cross-platform configs. Those configs are still present but deprecated in favor of chezmoi.
