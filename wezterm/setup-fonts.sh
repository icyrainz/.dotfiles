#!/usr/bin/env bash
# Symlink all user-installed fonts into the wezterm config fonts/ dir
# so ConfigDirsOnly can skip slow system font scanning.
#
# Usage: ./setup-fonts.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FONTS_DIR="$SCRIPT_DIR/fonts"

SEARCH_DIRS=(
  "$HOME/Library/Fonts"
  "$HOME/.local/share/fonts"
)

mkdir -p "$FONTS_DIR"

found=0
for dir in "${SEARCH_DIRS[@]}"; do
  [ -d "$dir" ] || continue
  for file in "$dir"/*.{ttf,ttc,otf}; do
    [ -e "$file" ] || continue
    name="$(basename "$file")"
    if [ ! -e "$FONTS_DIR/$name" ]; then
      ln -sf "$file" "$FONTS_DIR/$name"
      echo "  linked: $name"
    fi
    found=$((found + 1))
  done
done

echo "Done. $found font(s) in $FONTS_DIR"
