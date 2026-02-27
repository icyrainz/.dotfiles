#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- OS-aware package manager detection ---
OS=$(uname -s)
if [ "$OS" = "Darwin" ]; then
  PKG_MGR="brew"
elif command -v pacman &>/dev/null; then
  PKG_MGR="pacman"
elif command -v apt-get &>/dev/null; then
  PKG_MGR="apt"
else
  PKG_MGR=""
fi

# Prompt for sudo upfront (while we still have a TTY)
if [ "$PKG_MGR" = "pacman" ] || [ "$PKG_MGR" = "apt" ]; then
  sudo -v || { echo "!! sudo required for $PKG_MGR installs"; exit 1; }
fi

apt_updated=false
manual_installs=()

# --- Helper: install a tool by name ---
# Usage: pkg <display-name> [brew=<pkg>] [pacman=<pkg>] [apt=<pkg>] [script="<cmd>"] [manual=<url>]
pkg() {
  local name="$1"; shift
  local brew="" pacman="" apt="" script="" manual=""

  for arg in "$@"; do
    case "$arg" in
      brew=*)    brew="${arg#brew=}" ;;
      pacman=*)  pacman="${arg#pacman=}" ;;
      apt=*)     apt="${arg#apt=}" ;;
      script=*)  script="${arg#script=}" ;;
      manual=*)  manual="${arg#manual=}" ;;
    esac
  done

  # Look up package name for current manager
  local pkg_name=""
  case "$PKG_MGR" in
    brew)   pkg_name="$brew" ;;
    pacman) pkg_name="$pacman" ;;
    apt)    pkg_name="$apt" ;;
  esac

  if [ -n "$pkg_name" ]; then
    case "$PKG_MGR" in
      brew)   brew install "$pkg_name" ;;
      pacman) sudo pacman -S --needed --noconfirm "$pkg_name" ;;
      apt)
        if [ "$apt_updated" = false ]; then
          sudo apt-get update -qq
          apt_updated=true
        fi
        sudo apt-get install -y "$pkg_name"
        ;;
    esac
  elif [ -n "$script" ]; then
    if ! eval "$script"; then
      echo "!! $name: script install failed" >&2
    fi
  elif [ -n "$manual" ]; then
    manual_installs+=("$name -> $manual")
  else
    manual_installs+=("$name")
  fi
}

# --- Symlink helper for apt renames ---
apt_symlink() {
  local from="$1" to="$2"
  if [ "$PKG_MGR" = "apt" ] && command -v "$from" &>/dev/null && ! command -v "$to" &>/dev/null; then
    sudo ln -sf "$(command -v "$from")" "/usr/local/bin/$to"
  fi
}

# ============================================================
#  Tools — one entry per tool, alphabetical
# ============================================================

pkg bat          brew=bat        pacman=bat        apt=bat
apt_symlink batcat bat

pkg btop         brew=btop       pacman=btop       apt=btop
pkg bun          script="curl -fsSL https://bun.sh/install | bash"
pkg cowsay       brew=cowsay     pacman=cowsay     apt=cowsay
pkg curl         brew=curl       pacman=curl       apt=curl
pkg dust         brew=dust       pacman=dust       script="cargo install du-dust"

pkg fd           brew=fd         pacman=fd         apt=fd-find
apt_symlink fdfind fd

pkg fish         brew=fish       pacman=fish       apt=fish
pkg fnm          brew=fnm        script="curl -fsSL https://fnm.vercel.app/install | bash"
pkg fortune      brew=fortune    pacman=fortune-mod apt=fortune-mod
pkg fzf          brew=fzf        pacman=fzf        script="bash $SCRIPT_DIR/fzf/install.sh"
pkg gh           brew=gh         pacman=github-cli  manual="https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
pkg git          brew=git        pacman=git        apt=git
pkg htop         brew=htop       pacman=htop       apt=htop
pkg jq           brew=jq         pacman=jq         apt=jq
pkg lazygit      brew=lazygit    pacman=lazygit    manual="https://github.com/jesseduffield/lazygit#installation"
pkg lsd          brew=lsd        pacman=lsd        script="cargo install lsd"

pkg neovim       brew=neovim     pacman=neovim     manual="https://github.com/neovim/neovim/releases/latest"

pkg ripgrep      brew=ripgrep    pacman=ripgrep    apt=ripgrep
pkg sox          brew=sox
pkg sccache      brew=sccache    script="cargo install sccache"
pkg sesh         brew=sesh       script="bash $SCRIPT_DIR/sesh/install.sh"
pkg tmux         brew=tmux       pacman=tmux       apt=tmux
pkg tree         brew=tree       pacman=tree       apt=tree
pkg wget         brew=wget       pacman=wget       apt=wget
pkg whisper-cpp  brew=whisper-cpp
pkg worktrunk    brew=worktrunk  script="cargo install worktrunk"
pkg yazi         brew=yazi       pacman=yazi       manual="https://github.com/sxyazi/yazi/releases/latest"
pkg zoxide       brew=zoxide     pacman=zoxide     apt=zoxide
pkg zsh          brew=zsh        pacman=zsh        apt=zsh

# --- Fonts ---
if [ "$PKG_MGR" = "brew" ]; then
  brew install font-jetbrains-mono-nerd-font
else
  manual_installs+=("nerd-font -> https://www.nerdfonts.com/font-downloads")
fi

# --- Summary of tools needing manual install ---
if [ ${#manual_installs[@]} -gt 0 ]; then
  echo "" >&2
  echo "The following tools need manual installation:" >&2
  for item in "${manual_installs[@]}"; do
    echo "  - $item" >&2
  done
fi
