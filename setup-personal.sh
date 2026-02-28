#!/usr/bin/env bash
# Setup script for personal machines.
# Run after cloning the dotfiles repo and before ./install.
#
# Prerequisites:
#   - git-crypt installed (brew install git-crypt)
#   - mc (MinIO client) installed (brew install minio/stable/mc)
#   - RUSTFS_ACCESS_KEY and RUSTFS_SECRET_KEY set in environment
set -euo pipefail

# Create personal machine marker
if [ ! -f ~/.akio-personal ]; then
  touch ~/.akio-personal
  echo "Created ~/.akio-personal marker"
else
  echo "~/.akio-personal already exists"
fi

# Set up mc alias for RustFS
if ! mc alias list rustfs &>/dev/null 2>&1; then
  if [ -z "${RUSTFS_ACCESS_KEY:-}" ] || [ -z "${RUSTFS_SECRET_KEY:-}" ]; then
    echo "Error: RUSTFS_ACCESS_KEY and RUSTFS_SECRET_KEY must be set"
    exit 1
  fi
  mc alias set rustfs http://rustfs.lan "$RUSTFS_ACCESS_KEY" "$RUSTFS_SECRET_KEY"
  echo "Configured mc alias for rustfs"
fi

# Download git-crypt key and unlock
KEY=$(mktemp)
trap 'rm -f "$KEY"' EXIT
mc cp rustfs/git-crypt/dotfiles.key "$KEY"
git-crypt unlock "$KEY"
echo "Repository unlocked with git-crypt"

echo "Done. Run ./install to apply symlinks."
