# Dotfiles repo — conventions for Claude

## Management tool

Dotbot (not chezmoi). Symlink config lives in `install.conf.yaml`.
Run `./install` to apply all symlinks and run shell provisioners.

## Branch strategy

- `master` — shared base configs, works on any machine.
- Machine branches (e.g., `akio-macbook`) — machine-specific tweaks rebased on master.
- Branch names match the hostname in lowercase without `.local` suffix.

When making changes:
- If the change is universal (new tool, shared plugin config) → commit on `master`, then rebase machine branches.
- If the change is machine-specific (homebrew paths, SSH shortcuts, macOS-only settings) → commit on the machine branch only.
- Never merge machine branches into master.

## OS-conditional symlinks

`install.conf.yaml` uses dotbot's `if` directive for platform-specific links:
- `karabiner`, `hammerspoon` — macOS only (`uname = Darwin`)
- `sway` — Linux only (`uname = Linux`)

## install_tools.sh

Cross-platform tool installer. Supports brew (macOS), pacman (Arch), apt (Debian/Ubuntu).
Only include commonly useful tools — no niche or language-runtime packages (use asdf for those).
