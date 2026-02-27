#!/usr/bin/env bash
set -euo pipefail

# lazygit via brew/pacman is fine; not in apt repos.
command -v lazygit &>/dev/null && exit 0

repo="jesseduffield/lazygit"
arch=$(uname -m)
case "$arch" in
  x86_64)         lg_arch="x86_64" ;;
  aarch64|arm64)  lg_arch="arm64" ;;
  *)              echo "Unsupported architecture: $arch"; exit 1 ;;
esac

version=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" \
  | grep '"tag_name"' | head -1 | sed 's/.*"v\([^"]*\)".*/\1/')

if [ -z "$version" ]; then
  echo "Could not determine latest lazygit version"
  exit 1
fi

url="https://github.com/$repo/releases/download/v${version}/lazygit_${version}_Linux_${lg_arch}.tar.gz"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fsSL "$url" -o "$tmp/lazygit.tar.gz"
tar xzf "$tmp/lazygit.tar.gz" -C "$tmp"
sudo install -m 755 "$tmp/lazygit" /usr/local/bin/
echo "lazygit ${version} installed to /usr/local/bin/"
