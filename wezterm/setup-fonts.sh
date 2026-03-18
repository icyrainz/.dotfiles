#!/usr/bin/env bash
# Symlink fonts used by wezterm into the config fonts/ dir
# so ConfigDirsOnly can skip slow system font scanning.
#
# Usage: ./setup-fonts.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FONTS_DIR="$SCRIPT_DIR/fonts"

# Fonts needed by wezterm config (wezterm.local.lua)
FONT_PATTERNS=(
  "Iosevka*"
  "SymbolsNerdFontMono*"
)

# Common font directories to search
SEARCH_DIRS=(
  "$HOME/Library/Fonts"
  "/Library/Fonts"
  "/usr/share/fonts"
  "/usr/local/share/fonts"
  "$HOME/.local/share/fonts"
)

mkdir -p "$FONTS_DIR"

found=0
for pattern in "${FONT_PATTERNS[@]}"; do
  matched=false
  for dir in "${SEARCH_DIRS[@]}"; do
    [ -d "$dir" ] || continue
    for file in "$dir"/$pattern; do
      [ -e "$file" ] || continue
      name="$(basename "$file")"
      if [ ! -e "$FONTS_DIR/$name" ]; then
        ln -sf "$file" "$FONTS_DIR/$name"
        echo "  linked: $name -> $file"
      else
        echo "  exists: $name"
      fi
      matched=true
      found=$((found + 1))
    done
    # Stop searching other dirs once we found matches for this pattern
    $matched && break
  done
  if ! $matched; then
    echo "  MISSING: no match for $pattern"
  fi
done

echo ""
if [ "$found" -gt 0 ]; then
  echo "Done. $found font(s) linked in $FONTS_DIR"
else
  echo "No fonts found. Install Iosevka and Symbols Nerd Font first."
  exit 1
fi
