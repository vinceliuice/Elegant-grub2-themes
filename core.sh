
copy_files() {
  # Make a themes directory if it doesn't exist
  prompt -i "\n Checking themes directory ${THEME_DIR} ..."

  [[ -d "${THEME_DIR}" ]] && rm -rf "${THEME_DIR}"
  mkdir -p "${THEME_DIR}"

  # Copy theme
  prompt -i "\n Install in ${THEME_DIR} ..."

  # Don't preserve ownership because the owner will be root, and that causes the script to crash if it is ran from terminal by sudo
  cp -a --no-preserve=ownership "${REO_DIR}/common/"*.pf2 "${THEME_DIR}"
  cp -a --no-preserve=ownership "${REO_DIR}/backgrounds/backgrounds-${theme}/background-${theme}-${type}-${side}-${color}.jpg" "${THEME_DIR}/background.jpg"
  cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-icons-${color}/icons-${color}-${screen}" "${THEME_DIR}/icons"

  if [[ "${type}" == "blur" ]]; then
    cp -a --no-preserve=ownership "${REO_DIR}/config/theme-sharp-${side}-dark-${screen}.txt" "${THEME_DIR}/theme.txt"
    cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-other/other-${screen}/select_e-white.png" "${THEME_DIR}/select_e.png"
    cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-other/other-${screen}/select_c-white.png" "${THEME_DIR}/select_c.png"
    cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-other/other-${screen}/select_w-white.png" "${THEME_DIR}/select_w.png"
  else
    cp -a --no-preserve=ownership "${REO_DIR}/config/theme-${type}-${side}-${color}-${screen}.txt" "${THEME_DIR}/theme.txt"
    cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-other/other-${screen}/select_e-${theme}-${color}.png" "${THEME_DIR}/select_e.png"
    cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-other/other-${screen}/select_c-${theme}-${color}.png" "${THEME_DIR}/select_c.png"
    cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-other/other-${screen}/select_w-${theme}-${color}.png" "${THEME_DIR}/select_w.png"
  fi

  if [[ "${theme}" == "forest" ]]; then
    if [[ "${type}" == "blur" ]]; then
      cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-other/other-${screen}/sharp-${side}-alt.png" "${THEME_DIR}/info.png"
    else
      cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-other/other-${screen}/${type}-${side}-alt.png" "${THEME_DIR}/info.png"
    fi
  else
    if [[ "${type}" == "blur" ]]; then
      cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-other/other-${screen}/sharp-${side}.png" "${THEME_DIR}/info.png"
    else
      cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-other/other-${screen}/${type}-${side}.png" "${THEME_DIR}/info.png"
    fi
  fi

  prompt -i "\n Install ${logoicon} logo."
  if [[ -f "${REO_DIR}/assets/assets-other/other-${screen}/${logoicon}.png" ]]; then
    cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-other/other-${screen}/${logoicon}.png" "${THEME_DIR}/logo.png"
  else
    prompt -w "\n Did not find ${logoicon} logo ! install default one."
    cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-other/other-${screen}/Default.png" "${THEME_DIR}/logo.png"
  fi

  # Use custom background.jpg as grub background image
  if [[ -f "${REO_DIR}/background.jpg" ]]; then
    prompt -w "\n Using custom background.jpg as grub background image..."
    cp -a --no-preserve=ownership "${REO_DIR}/background.jpg" "${THEME_DIR}/background.jpg"
    convert -auto-orient "${THEME_DIR}/background.jpg" "${THEME_DIR}/background.jpg"
  fi
}

