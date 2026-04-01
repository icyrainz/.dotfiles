#!/usr/bin/env bash
set -euo pipefail

# mc (MinIO Client) via brew/pacman is fine; this handles other distros.
command -v mc &>/dev/null && exit 0

arch=$(uname -m)
case "$arch" in
  x86_64)         mc_arch="amd64" ;;
  aarch64|arm64)  mc_arch="arm64" ;;
  *)              echo "Unsupported architecture: $arch"; exit 1 ;;
esac

url="https://dl.min.io/client/mc/release/linux-${mc_arch}/mc"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fsSL "$url" -o "$tmp/mc"

source "$(dirname "$0")/../lib/sudo.sh"
$SUDO install -m 755 "$tmp/mc" /usr/local/bin/
echo "mc installed to /usr/local/bin/"
