## Shells
zsh -> fish

Fisher plugins:
- jorgebucaran/fisher
- jethrokuan/z
- budimanjojo/tmux.fish
- jethrokuan/fzf
- ilancosman/tide@v5
- jorgebucaran/nvm.fish

## Terminal emulators
iterm2 -> kitty -> alacritty -> wezterm

## Multiplexers
tmux -> wezterm

## Dotfiles Management

This repository uses two dotfile managers:
- **dotbot**: For cross-platform configs (macOS + Linux) - nvim, tmux, wezterm, fish, etc.
- **chezmoi**: For Linux-specific configs - sway window manager, etc.

## Install

### macOS / Cross-platform configs:
```bash
git clone https://github.com/icyrainz/.dotfiles.git --recursive
cd dotfiles && ./install
```

### Linux-specific configs (chezmoi):
```bash
# Install chezmoi (Arch Linux)
pacman -S chezmoi

# Configure chezmoi to use this repo's chezmoi directory
mkdir -p ~/.config/chezmoi
echo 'sourceDir = "/path/to/.dotfiles/chezmoi"' > ~/.config/chezmoi/chezmoi.toml

# Apply chezmoi configs
chezmoi apply
```

**Note**: Replace `/path/to/.dotfiles/chezmoi` with the actual path to your cloned repo.
