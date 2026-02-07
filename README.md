# Dotfiles

Personal dotfiles managed with [dotbot](https://github.com/anishathalye/dotbot).

## What's Included

| Config | Description |
|--------|-------------|
| zsh | Shell config with aliases, zoxide, fzf |
| bash | Bash config with fzf integration |
| nvim | Neovim with LazyVim |
| wezterm | Terminal emulator |
| tmux | Terminal multiplexer |
| fish | Fish shell config |
| karabiner | macOS keyboard remapping |
| hammerspoon | macOS automation |
| doom | Doom Emacs config |
| ideavim | JetBrains IdeaVim config |
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

```bash
git clone https://github.com/icyrainz/.dotfiles.git ~/repo/.dotfiles
cd ~/repo/.dotfiles
./install
```

Dotbot will create symlinks for all configs. To set zsh as default shell:

```bash
chsh -s $(which zsh)
```

## Post-migration cleanup

If you previously used chezmoi, you can clean up:

```bash
rm -rf ~/.config/chezmoi
# Optionally: brew uninstall chezmoi / pacman -R chezmoi
```
