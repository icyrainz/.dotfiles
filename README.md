# Dotfiles

Personal dotfiles managed with [dotbot](https://github.com/anishathalye/dotbot).

## What's Included

| Config | Description |
|--------|-------------|
| fish | Fish shell config (primary shell) |
| zsh | Zsh config with aliases, zoxide, fzf |
| bash | Bash config with fzf integration |
| nvim | Neovim with LazyVim |
| tmux | Terminal multiplexer |
| ghostty | Terminal emulator |
| wezterm | Terminal emulator |
| lazygit | Git TUI |
| sesh | Tmux session manager |
| fzf | Fuzzy finder config |
| git | Git hooks |
| gh | GitHub CLI config |
| yazi | Terminal file manager |
| helix | Helix editor config |
| hammerspoon | macOS automation |
| doom | Doom Emacs config |
| ideavim | JetBrains IdeaVim config |
| claude | Claude Code settings, skills, statusline |
| opencode | OpenCode config |
| peon-ping | Sound notification config |
| lxc-bootstrap | LXC container provisioning scripts |
| patched-fonts | Custom patched Nerd Fonts |
| ytdl-sub | yt-dlp subscription config |

## Install

```bash
git clone https://github.com/icyrainz/.dotfiles.git ~/Github/.dotfiles
cd ~/Github/.dotfiles
./install
```

Dotbot creates symlinks for all configs and runs shell provisioners for tools, plugins, etc.

### Personal machines

Personal machines get additional configs (homelab skills, opencode endpoints). Set up the marker file and decrypt:

```bash
touch ~/.akio-personal
git-crypt unlock /path/to/git-crypt-dotfiles.key
./install
```

### What the marker controls

| Gated by `~/.akio-personal` | What |
|------------------------------|------|
| `claude/skills-personal/*` | Homelab, HAOS, Homepage skills |
| `opencode/opencode.json` | OpenCode config with personal endpoints |

### What git-crypt encrypts

| Encrypted | Why |
|-----------|-----|
| `claude/skills-personal/**` | Contains personal infrastructure details |

Export the key for new machines: `git-crypt export-key ~/git-crypt-dotfiles.key`

## OS-Conditional Configs

Dotbot's `if` directive handles platform-specific links:

- `hammerspoon` — macOS only

## Required CLI Tools

Handled by `install_tools.sh` which supports brew (macOS), pacman (Arch), and apt (Debian/Ubuntu). Only commonly useful tools — no niche or language-runtime packages (use asdf/fnm for those).

**Convention:** When installing a new CLI tool, always consider adding it to `install_tools.sh` for cross-platform availability.

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
