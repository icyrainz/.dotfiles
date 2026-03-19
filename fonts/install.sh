#!/bin/bash
# Install terminal fonts (Iosevka Term + Symbols Nerd Font)
# macOS: uses Homebrew casks
# Linux: downloads from GitHub releases to ~/.local/share/fonts
set -euo pipefail

OS=$(uname -s)

if [ "$OS" = "Darwin" ]; then
  brew install font-iosevka font-symbols-only-nerd-font
  exit 0
fi

FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

install_github_font() {
  local name="$1" repo="$2" pattern="$3"
  if ls "$FONT_DIR/$name"/*.ttf &>/dev/null || ls "$FONT_DIR/$name"/*.ttc &>/dev/null; then
    echo ":: $name already installed, skipping"
    return
  fi
  echo ":: Installing $name ..."
  local tmpdir
  tmpdir=$(mktemp -d)
  local url
  url=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" \
    | grep -o "\"browser_download_url\": *\"[^\"]*${pattern}[^\"]*\"" \
    | head -1 | cut -d'"' -f4)
  if [ -z "$url" ]; then
    echo "!! Could not find download URL for $name"
    echo "   Manual install: https://github.com/$repo/releases"
    rm -rf "$tmpdir"
    return 1
  fi
  curl -fsSL "$url" -o "$tmpdir/font.zip"
  mkdir -p "$FONT_DIR/$name"
  unzip -qo "$tmpdir/font.zip" -d "$FONT_DIR/$name"
  rm -rf "$tmpdir"
  echo "   installed to $FONT_DIR/$name"
}

install_github_font "IosevkaTerm" "be5invis/Iosevka" "PkgTTF-IosevkaTerm-"
install_github_font "SymbolsNerdFont" "ryanoasis/nerd-fonts" "NerdFontsSymbolsOnly"
fc-cache -f
