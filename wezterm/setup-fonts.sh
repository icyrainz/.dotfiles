#!/usr/bin/env bash
# Symlink fonts listed in fonts.list into the wezterm config fonts/ dir
# so ConfigDirsOnly can skip slow system font scanning.
#
# Usage: ./setup-fonts.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FONTS_DIR="$SCRIPT_DIR/fonts"
FONTS_LIST="$SCRIPT_DIR/fonts.list"

if [ ! -f "$FONTS_LIST" ]; then
  echo "Missing $FONTS_LIST — add font glob patterns, one per line."
  exit 1
fi

SEARCH_DIRS=(
  "$HOME/Library/Fonts"
  "$HOME/.local/share/fonts"
  "/usr/share/fonts"
  "/usr/local/share/fonts"
)

mkdir -p "$FONTS_DIR"

found=0
while IFS= read -r pattern || [ -n "$pattern" ]; do
  [ -z "$pattern" ] && continue
  [[ "$pattern" == \#* ]] && continue
  matched=false
  for dir in "${SEARCH_DIRS[@]}"; do
    [ -d "$dir" ] || continue
    for file in "$dir"/$pattern; do
      [ -e "$file" ] || continue
      name="$(basename "$file")"
      ln -sf "$file" "$FONTS_DIR/$name"
      echo "  linked: $name"
      matched=true
      found=$((found + 1))
    done
    $matched && break
  done
  if ! $matched; then
    echo "  MISSING: $pattern"
  fi
done < "$FONTS_LIST"

echo "Done. $found font(s) in $FONTS_DIR"
