#!/bin/bash

INKSCAPE="/usr/bin/inkscape"
OPTIPNG="/usr/bin/optipng"

if [[ "$1" == "other" ]]; then
  EXPORT_TYPE="other"
  INDEX="other.txt"
  SRC_FILE="other.svg"
elif [[ "$1" == "icons-light" ]]; then
  EXPORT_TYPE="icons-light"
  INDEX="icons.txt"
  SRC_FILE="icons-light.svg"
elif [[ "$1" == "icons-dark" ]]; then
  EXPORT_TYPE="icons-dark"
  INDEX="icons.txt"
  SRC_FILE="icons-dark.svg"
fi

if [[ "$2" == "1080p" ]]; then
  ASSETS_DIR="assets-$EXPORT_TYPE/$EXPORT_TYPE-1080p"
  EXPORT_DPI="96"
elif [[ "$2" == "2k" ]] || [[ "$2" == "2K" ]]; then
  ASSETS_DIR="assets-$EXPORT_TYPE/$EXPORT_TYPE-2k"
  EXPORT_DPI="144"
elif [[ "$2" == "4k" ]] || [[ "$2" == "4K" ]]; then
  ASSETS_DIR="assets-$EXPORT_TYPE/$EXPORT_TYPE-4k"
  EXPORT_DPI="192"
else
  echo "Please use either '1080p', '2k' or '4k'"
  exit 1
fi

install -d "$ASSETS_DIR"

while read -r i; do
  if [[ -f "$ASSETS_DIR/$i.png" ]]; then
    echo "$ASSETS_DIR/$i.png exists"
  elif [[ "$i" == "" ]]; then
    continue
  else
    echo -e "\nRendering $ASSETS_DIR/$i.png"
    $INKSCAPE "--export-id=$i" \
              "--export-dpi=$EXPORT_DPI" \
              "--export-id-only" \
              "--export-filename=$ASSETS_DIR/$i.png" "$SRC_FILE" >/dev/null
    $OPTIPNG -strip all -nc "$ASSETS_DIR/$i.png"
  fi
done < "$INDEX"

if [[ "$EXPORT_TYPE" == "icons-light" || "$EXPORT_TYPE" == "icons-dark" ]]; then
  cd "$ASSETS_DIR" || exit 1
  cp -a archlinux.png arch.png
  cp -a gnu-linux.png linux.png
  cp -a gnu-linux.png unknown.png
  cp -a gnu-linux.png lfs.png
  cp -a manjaro.png Manjaro.i686.png
  cp -a manjaro.png Manjaro.x86_64.png
  cp -a manjaro.png manjarolinux.png
  cp -a pop-os.png pop.png
  cp -a driver.png memtest.png
fi
exit 0
