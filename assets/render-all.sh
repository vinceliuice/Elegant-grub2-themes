#!/bin/bash

VARIANTS=("icons-light" "icons-dark" "other")
RESOLUTIONS=("1080p" "2k" "4k")

for variant in "${VARIANTS[@]}"; do
  for resolution in "${RESOLUTIONS[@]}"; do
    echo "./render-assets.sh \"$resolution\": "
    ./render-assets.sh "$variant" "$resolution"
  done
done
