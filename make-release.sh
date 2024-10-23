#! /bin/bash

OPEN_DIR=$(cd $(dirname $0) && pwd)

THEME_NAME=Elegant

SCREEN_VARIANTS=('1080p' '2k' '4k')
THEME_VARIANTS=('forest' 'mojave' 'mountain' 'wave')
TYPE_VARIANTS=('window' 'float' 'sharp' 'blur')
SIDE_VARIANTS=('left' 'right')
COLOR_VARIANTS=('dark' 'light')

screens=()
themes=()
types=()
sides=()
colors=()

if [[ "${#screens[@]}" -eq 0 ]] ; then
  screens=("${SCREEN_VARIANTS[@]}")
fi

if [[ "${#themes[@]}" -eq 0 ]] ; then
  themes=("${THEME_VARIANTS[@]}")
fi

if [[ "${#types[@]}" -eq 0 ]] ; then
  types=("${TYPE_VARIANTS[@]}")
fi

if [[ "${#sides[@]}" -eq 0 ]] ; then
  sides=("${SIDE_VARIANTS[@]}")
fi

if [[ "${#colors[@]}" -eq 0 ]] ; then
  colors=("${COLOR_VARIANTS[@]}")
fi

Tar_themes() {
  for theme in "${themes[@]}"; do
    for type in "${types[@]}"; do
      rm -rf ${THEME_NAME}-${theme}-${type}-grub-themes.tar
      rm -rf ${THEME_NAME}-${theme}-${type}-grub-themes.tar.xz
    done
  done

  for theme in "${themes[@]}"; do
    for type in "${types[@]}"; do
      tar -Jcvf ${THEME_NAME}-${theme}-${type}-grub-themes.tar.xz ${THEME_NAME}-${theme}-${type}-grub-themes
    done
  done
}

Clear_theme() {
  for theme in "${themes[@]}"; do
    for type in "${types[@]}"; do
      rm -rf ${THEME_NAME}-${theme}-${type}-grub-themes
    done
  done
}

for theme in "${themes[@]}"; do
  for type in "${types[@]}"; do
    for side in "${sides[@]}"; do
      for color in "${colors[@]}"; do
        for screen in "${screens[@]}"; do
          ./generate.sh -d "$OPEN_DIR/releases/${THEME_NAME}-${theme}-${type}-grub-themes/${side}-${color}-${screen}" -t "${theme}" -p "${type}" -i "${side}" -c "${color}" -s "${screen}" -l default
          cp -rf "$OPEN_DIR/releases/"install "$OPEN_DIR/releases/${THEME_NAME}-${theme}-${type}-grub-themes/${side}-${color}-${screen}"/install.sh
          cp -rf "$OPEN_DIR/backgrounds/previews/preview-${theme}-${type}-${side}-${color}.jpg" "$OPEN_DIR/releases/${THEME_NAME}-${theme}-${type}-grub-themes/${side}-${color}-${screen}/preview.jpg"
          sed -i "s/grub_theme_name/${THEME_NAME}-${theme}-${type}-${side}-${color}/g" "$OPEN_DIR/releases/${THEME_NAME}-${theme}-${type}-grub-themes/${side}-${color}-${screen}"/install.sh
        done
      done
    done
  done
done

cd "$OPEN_DIR/releases"

Tar_themes && Clear_theme

