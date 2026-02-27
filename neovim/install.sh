#!/usr/bin/env bash
set -euo pipefail

# neovim via brew/pacman is fine; apt ships an old version.
command -v nvim &>/dev/null && exit 0

arch=$(uname -m)
case "$arch" in
  x86_64)         nvim_arch="x86_64" ;;
  aarch64|arm64)  nvim_arch="arm64" ;;
  *)              echo "Unsupported architecture: $arch"; exit 1 ;;
esac

asset="nvim-linux-${nvim_arch}.tar.gz"
url="https://github.com/neovim/neovim/releases/latest/download/${asset}"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fsSL "$url" -o "$tmp/$asset"
tar xzf "$tmp/$asset" -C "$tmp"
sudo cp -r "$tmp/nvim-linux-${nvim_arch}"/* /usr/local/
echo "neovim installed to /usr/local/bin/nvim"
