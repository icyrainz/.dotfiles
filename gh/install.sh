#!/usr/bin/env bash
set -euo pipefail

# gh via brew/pacman is fine; not in apt repos by default.
command -v gh &>/dev/null && exit 0

repo="cli/cli"
arch=$(uname -m)
case "$arch" in
  x86_64)         gh_arch="amd64" ;;
  aarch64|arm64)  gh_arch="arm64" ;;
  *)              echo "Unsupported architecture: $arch"; exit 1 ;;
esac

version=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" \
  | grep '"tag_name"' | head -1 | sed 's/.*"v\([^"]*\)".*/\1/')

if [ -z "$version" ]; then
  echo "Could not determine latest gh version"
  exit 1
fi

url="https://github.com/$repo/releases/download/v${version}/gh_${version}_linux_${gh_arch}.tar.gz"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fsSL "$url" -o "$tmp/gh.tar.gz"
tar xzf "$tmp/gh.tar.gz" -C "$tmp"
sudo install -m 755 "$tmp/gh_${version}_linux_${gh_arch}/bin/gh" /usr/local/bin/
echo "gh ${version} installed to /usr/local/bin/"
