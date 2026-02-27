#!/usr/bin/env bash
set -euo pipefail

# yazi via brew/pacman is fine; not in apt repos.
command -v yazi &>/dev/null && exit 0

repo="sxyazi/yazi"
arch=$(uname -m)
case "$arch" in
  x86_64)         target="x86_64-unknown-linux-musl" ;;
  aarch64|arm64)  target="aarch64-unknown-linux-musl" ;;
  *)              echo "Unsupported architecture: $arch"; exit 1 ;;
esac

version=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" \
  | grep '"tag_name"' | head -1 | sed 's/.*"\([^"]*\)".*/\1/')

if [ -z "$version" ]; then
  echo "Could not determine latest yazi version"
  exit 1
fi

url="https://github.com/$repo/releases/download/${version}/yazi-${target}.zip"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fsSL "$url" -o "$tmp/yazi.zip"
unzip -q "$tmp/yazi.zip" -d "$tmp"
sudo install -m 755 "$tmp/yazi-${target}/yazi" /usr/local/bin/
sudo install -m 755 "$tmp/yazi-${target}/ya" /usr/local/bin/
echo "yazi ${version} installed to /usr/local/bin/"
