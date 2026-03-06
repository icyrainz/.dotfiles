#!/usr/bin/env bash
set -euo pipefail

# fzf via brew/pacman is fine; apt ships an old version.
# install_tools.sh runs first, so if fzf is already current, skip.
command -v fzf &>/dev/null && exit 0

repo="junegunn/fzf"
arch=$(uname -m)
case "$arch" in
  x86_64)  asset_pattern="linux_amd64.tar.gz" ;;
  aarch64) asset_pattern="linux_arm64.tar.gz" ;;
  *)       echo "Unsupported architecture: $arch"; exit 1 ;;
esac

url=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" \
  | grep "browser_download_url" | grep "$asset_pattern" \
  | head -1 | cut -d '"' -f 4)

if [ -z "$url" ]; then
  echo "Could not find fzf release for $asset_pattern"
  exit 1
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fsSL "$url" -o "$tmp/fzf.tar.gz"
tar xzf "$tmp/fzf.tar.gz" -C "$tmp"
source "$(dirname "$0")/../lib/sudo.sh"
$SUDO install -m 755 "$tmp/fzf" /usr/local/bin/
echo "fzf installed to /usr/local/bin/"
