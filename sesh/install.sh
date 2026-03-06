#!/usr/bin/env bash
set -euo pipefail

# sesh via brew/pacman is fine; not in apt repos.
# install_tools.sh runs first, so if sesh is already installed, skip.
command -v sesh &>/dev/null && exit 0

repo="joshmedeski/sesh"
arch=$(uname -m)
case "$arch" in
  x86_64)  asset_pattern="Linux_x86_64.tar.gz" ;;
  aarch64) asset_pattern="Linux_arm64.tar.gz" ;;
  *)       echo "Unsupported architecture: $arch"; exit 1 ;;
esac

url=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" \
  | grep "browser_download_url" | grep "$asset_pattern" \
  | head -1 | cut -d '"' -f 4)

if [ -z "$url" ]; then
  echo "Could not find sesh release for $asset_pattern"
  exit 1
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fsSL "$url" -o "$tmp/sesh.tar.gz"
tar xzf "$tmp/sesh.tar.gz" -C "$tmp"
source "$(dirname "$0")/../lib/sudo.sh"
$SUDO install -m 755 "$tmp/sesh" /usr/local/bin/
echo "sesh installed to /usr/local/bin/"
