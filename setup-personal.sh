#!/usr/bin/env bash
# Setup script for personal machines.
# Run after cloning the dotfiles repo and before ./install.
# Installs dependencies, prompts for RustFS credentials, and unlocks git-crypt.
set -euo pipefail

# --- OS-aware package manager detection ---
OS=$(uname -s)
if [ "$OS" = "Darwin" ]; then
  PKG_MGR="brew"
elif command -v pacman &>/dev/null; then
  PKG_MGR="pacman"
elif command -v apt-get &>/dev/null; then
  PKG_MGR="apt"
else
  echo "Error: No supported package manager found (brew, pacman, apt)"
  exit 1
fi

# --- Install git-crypt ---
if ! command -v git-crypt &>/dev/null; then
  echo "Installing git-crypt..."
  case "$PKG_MGR" in
    brew)   brew install git-crypt ;;
    pacman) sudo pacman -S --needed --noconfirm git-crypt ;;
    apt)    sudo apt-get update -qq && sudo apt-get install -y git-crypt ;;
  esac
else
  echo "git-crypt already installed"
fi

# --- Install mc (MinIO client) ---
# Binary name varies: mc on macOS/apt, mcli on Arch
find_mc() {
  for cmd in mc mcli; do
    if command -v "$cmd" &>/dev/null && "$cmd" --version 2>/dev/null | grep -q "mc version"; then
      echo "$cmd"; return
    fi
  done
}

MC=$(find_mc)
if [ -z "$MC" ]; then
  echo "Installing mc (MinIO client)..."
  case "$PKG_MGR" in
    brew)   brew install minio/stable/mc ;;
    pacman) sudo pacman -S --needed --noconfirm minio-client ;;
    apt)    curl -fsSL https://dl.min.io/client/mc/release/linux-amd64/mc -o /usr/local/bin/mc && chmod +x /usr/local/bin/mc ;;
  esac
  MC=$(find_mc)
else
  echo "mc already installed ($MC)"
fi

# --- Create personal machine marker ---
if [ ! -f ~/.akio-personal ]; then
  touch ~/.akio-personal
  echo "Created ~/.akio-personal marker"
else
  echo "~/.akio-personal already exists"
fi

# --- Set up mc alias for RustFS ---
if ! $MC alias list rustfs &>/dev/null 2>&1; then
  echo ""
  echo "Enter RustFS credentials (from Bitwarden):"
  read -rp "  Access Key: " RUSTFS_ACCESS_KEY
  read -rsp "  Secret Key: " RUSTFS_SECRET_KEY
  echo ""
  $MC alias set rustfs http://rustfs.lan "$RUSTFS_ACCESS_KEY" "$RUSTFS_SECRET_KEY"
  echo "Configured mc alias for rustfs"
else
  echo "mc alias for rustfs already configured"
fi

# --- Download git-crypt key and unlock ---
KEY=$(mktemp)
trap 'rm -f "$KEY"' EXIT
$MC cp rustfs/git-crypt/dotfiles.key "$KEY"
git-crypt unlock "$KEY"
echo "Repository unlocked with git-crypt"

echo ""
echo "Done. Run ./install to apply symlinks."
