#!/bin/bash

INKSCAPE="/usr/bin/inkscape"
OPTIPNG="/usr/bin/optipng"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

THEME_VARIANTS=('-forest' '-mojave' '-mountain' '-wave')
TYPE_VARIANTS=('-window' '-float' '-sharp' '-blur')
SIDE_VARIANTS=('-left' '-right')
COLOR_VARIANTS=('-light' '-dark')

render_preview() {
  local theme="${1}"
  local type="${2}"
  local side="${3}"
  local color="${4}"

  local FILEID="preview${theme}${type}${side}${color}"
  local FILENAME="$REPO_DIR/previews/$FILEID"

  mkdir -p "$REPO_DIR/previews"

  if [[ -f "$FILENAME.jpg" ]]; then
    echo "$FILENAME exists"
  else
    echo -e "\nRendering $FILENAME.png"
    $INKSCAPE "--export-id=$FILEID" \
              "--export-dpi=96" \
              "--export-id-only" \
              "--export-filename=$FILENAME.png" "previews${theme}.svg" >/dev/null
    convert "$FILENAME.png" "$FILENAME.jpg"
  fi

  rm -rf "$FILENAME.png"
}

for theme in "${THEME_VARIANTS[@]}"; do
for type in "${TYPE_VARIANTS[@]}"; do
for side in "${SIDE_VARIANTS[@]}"; do
for color in "${COLOR_VARIANTS[@]}"; do
  render_preview "${theme}" "${type}" "${side}" "${color}"
done
done
done
done

exit 0
