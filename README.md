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

## Tmux Keybindings

Prefix is `C-Space`.

### Popups (all 70%)

| Key | Description |
|-----|-------------|
| `Ctrl+]` | Sesh session picker (no prefix needed) |
| `prefix + t` | Sesh session picker |
| `prefix + e` | File picker (fzf + bat preview) → open in nvim. `^a` show all, `^g` default |
| `prefix + '` | Ripgrep search → open result in nvim at exact line |
| `prefix + s` | Scratch terminal |
| `prefix + g` | Lazygit |
| `prefix + w` | Worktree picker |
| `prefix + h` | Task monitor |
| `prefix + f` | Fuzzy switch windows in current session |

### Panes & Windows

| Key | Description |
|-----|-------------|
| `prefix + \` or `\|` | Split horizontal |
| `prefix + -` or `_` | Split vertical |
| `Ctrl+h/j/k/l` | Navigate panes (vim-aware) |
| `Alt+Arrow` | Resize panes |
| `prefix + m` | Maximize/restore pane |
| `prefix + <` / `>` | Swap windows left/right |

### Session & Window Management

| Key | Description |
|-----|-------------|
| `prefix + k` | Kill all panes except current (confirm) |
| `prefix + K` | Kill all panes except current (no confirm) |
| `prefix + X` | Kill pane (no confirm) |
| `prefix + W` | Kill window (confirm) |
| `prefix + S` | Save session (resurrect) |
| `prefix + L` | Restore session (resurrect) |
| `prefix + l` | Clear scrollback |

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

## Machine-Specific Configs

The `master` branch contains shared configs that work on any machine. Machine-specific
tweaks live on branches named after the hostname (e.g., `akio-macbook`).

### Setup on a new/existing machine

```bash
# After cloning and running ./install with the shared base:
git checkout -b $(hostname | tr '[:upper:]' '[:lower:]' | sed 's/\.local$//')
# Make machine-specific changes, commit to this branch
```

### Day-to-day workflow

- **Shared change** (new tool, plugin config everyone needs): commit on `master`, then rebase machine branches.
- **Machine-specific change** (paths, SSH hosts, macOS-only tweaks): commit on the machine branch.

```bash
# After committing shared changes on master:
git checkout akio-macbook
git rebase master
```

### Existing machine branches

| Branch | Machine |
|--------|---------|
| `akio-macbook` | MacBook (macOS) |
