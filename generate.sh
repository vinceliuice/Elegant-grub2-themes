#! /usr/bin/env bash

# Exit Immediately if a command fails
set -o errexit

readonly Project_Name="GRUB2::THEMES"
readonly MAX_DELAY=20                               # max delay for user to enter root password

THEME_NAME=Elegant
REO_DIR="$(cd $(dirname $0) && pwd)"

SCREEN_VARIANTS=('1080p' '2k' '4k')
THEME_VARIANTS=('forest' 'mojave' 'mountain' 'wave')
TYPE_VARIANTS=('window' 'float' 'sharp')
SIDE_VARIANTS=('left' 'right')
COLOR_VARIANTS=('dark' 'light')

screens=()
themes=()
types=()
sides=()
colors=()

logoicon="Empty"

#################################
#   :::::: C O L O R S ::::::   #
#################################

CDEF=" \033[0m"                                     # default color
CCIN=" \033[0;36m"                                  # info color
CGSC=" \033[0;32m"                                  # success color
CRER=" \033[0;31m"                                  # error color
CWAR=" \033[0;33m"                                  # waring color
b_CDEF=" \033[1;37m"                                # bold default color
b_CCIN=" \033[1;36m"                                # bold info color
b_CGSC=" \033[1;32m"                                # bold success color
b_CRER=" \033[1;31m"                                # bold error color
b_CWAR=" \033[1;33m"                                # bold warning color

#######################################
#   :::::: F U N C T I O N S ::::::   #
#######################################

# echo like ... with flag type and display message colors
prompt () {
  case ${1} in
    "-s"|"--success")
      echo -e "${b_CGSC}${@/-s/}${CDEF}";;    # print success message
    "-e"|"--error")
      echo -e "${b_CRER}${@/-e/}${CDEF}";;    # print error message
    "-w"|"--warning")
      echo -e "${b_CWAR}${@/-w/}${CDEF}";;    # print warning message
    "-i"|"--info")
      echo -e "${b_CCIN}${@/-i/}${CDEF}";;    # print info message
    *)
    echo -e "$@"
    ;;
  esac
}

# Check command availability
function has_command() {
  command -v $1 &> /dev/null #with "&>", all output will be redirected.
}

usage() {
cat << EOF

Usage: $0 [OPTION]...

OPTIONS:
  -t, --theme     Background theme variant(s) [forest|mojave|mountain|wave] (default is forest)
  -p, --type      Theme style variant(s)      [window|float|sharp] (default is window)
  -i, --side      Picture display side        [left|right] (default is left)
  -c, --color     Background color variant(s) [dark|light] (default is dark)
  -s, --screen    Screen display variant(s)   [1080p|2k|4k] (default is 1080p)
  -l, --logo      Show a logo on picture      [default|system] (default: a mountain logo)

  -h, --help      Show this help

EOF
}

generate() {
  local dest="${1}"
  local theme="${2}"
  local type="${3}"
  local side="${4}"
  local color="${5}"
  local screen="${6}"

  local THEME_DIR="${1}/${THEME_NAME}-${2}-${3}-${4}-${5}"

  # Make a themes directory if it doesn't exist
  prompt -i "\n Checking themes directory ${THEME_DIR} ..."

  [[ -d "${THEME_DIR}" ]] && rm -rf "${THEME_DIR}"
  mkdir -p "${THEME_DIR}"

  # Copy theme
  prompt -i "\n Installing Wuthering-${theme} ${screen} theme ..."

  # Don't preserve ownership because the owner will be root, and that causes the script to crash if it is ran from terminal by sudo
  cp -a --no-preserve=ownership "${REO_DIR}/common/"*.pf2 "${THEME_DIR}"
  cp -a --no-preserve=ownership "${REO_DIR}/config/theme-${type}-${side}-${color}-${screen}.txt" "${THEME_DIR}/theme.txt"
  cp -a --no-preserve=ownership "${REO_DIR}/backgrounds/backgrounds-${theme}/background-${theme}-${type}-${side}-${color}.jpg" "${THEME_DIR}/background.jpg"
  cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-icons-${color}/icons-${color}-${screen}" "${THEME_DIR}/icons"
  cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-other/other-${screen}/select_e-${theme}-${color}.png" "${THEME_DIR}/select_e.png"
  cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-other/other-${screen}/select_c-${theme}-${color}.png" "${THEME_DIR}/select_c.png"
  cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-other/other-${screen}/select_w-${theme}-${color}.png" "${THEME_DIR}/select_w.png"
  cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-other/other-${screen}/${type}-${side}.png" "${THEME_DIR}/info.png"

  prompt -i "\n Install ${logoicon} logo."
  cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-other/other-${screen}/${logoicon}.png" "${THEME_DIR}/logo.png"

  # Use custom background.jpg as grub background image
  if [[ -f "${REO_DIR}/background.jpg" ]]; then
    prompt -w "\n Using custom background.jpg as grub background image..."
    cp -a --no-preserve=ownership "${REO_DIR}/background.jpg" "${THEME_DIR}/background.jpg"
    convert -auto-orient "${THEME_DIR}/background.jpg" "${THEME_DIR}/background.jpg"
  fi

  prompt -s "\n Finished ..."
}

while [[ $# -gt 0 ]]; do
  case "${1}" in
    -d|--dest)
      dest="${2}"
      if [[ ! -d "${dest}" ]]; then
        echo -e "\nDestination directory does not exist. Let's make a new one..."
        mkdir -p ${dest}
      fi
      shift 2
      ;;
    -t|--theme)
      shift
      for theme in "${@}"; do
        case "${theme}" in
          forest)
            themes+=("${THEME_VARIANTS[0]}")
            shift
            ;;
          mojave)
            themes+=("${THEME_VARIANTS[1]}")
            shift
            ;;
          mountain)
            themes+=("${THEME_VARIANTS[2]}")
            shift
            ;;
          wave)
            themes+=("${THEME_VARIANTS[3]}")
            shift
            ;;
          -*)
            break
            ;;
          *)
            prompt -e "ERROR: Unrecognized theme variant '$1'."
            prompt -i "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -p|--type)
      shift
      for type in "${@}"; do
        case "${type}" in
          window)
            types+=("${TYPE_VARIANTS[0]}")
            shift
            ;;
          float)
            types+=("${TYPE_VARIANTS[1]}")
            shift
            ;;
          sharp)
            types+=("${TYPE_VARIANTS[2]}")
            shift
            ;;
          -*)
            break
            ;;
          *)
            prompt -e "ERROR: Unrecognized type variant '$1'."
            prompt -i "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -i|--side)
      shift
      for side in "${@}"; do
        case "${side}" in
          left)
            sides+=("${SIDE_VARIANTS[0]}")
            shift
            ;;
          right)
            sides+=("${SIDE_VARIANTS[1]}")
            shift
            ;;
          -*)
            break
            ;;
          *)
            prompt -e "ERROR: Unrecognized side variant '$1'."
            prompt -i "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -c|--color)
      shift
      for color in "${@}"; do
        case "${color}" in
          dark)
            colors+=("${COLOR_VARIANTS[0]}")
            shift
            ;;
          light)
            colors+=("${COLOR_VARIANTS[1]}")
            shift
            ;;
          -*)
            break
            ;;
          *)
            prompt -e "ERROR: Unrecognized color variant '$1'."
            prompt -i "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -s|--screen)
      shift
      for screen in "${@}"; do
        case "${screen}" in
          1080p)
            screens+=("${SCREEN_VARIANTS[0]}")
            shift
            ;;
          2k)
            screens+=("${SCREEN_VARIANTS[1]}")
            shift
            ;;
          4k)
            screens+=("${SCREEN_VARIANTS[2]}")
            shift
            ;;
          -*)
            break
            ;;
          *)
            prompt -e "ERROR: Unrecognized screen variant '$1'."
            prompt -i "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -l|--logo)
      shift
      for logo in "${@}"; do
        case "${logo}" in
          default)
            logoicon="Default"
            shift
            ;;
          system)
            logoicon="$(lsb_release -i | cut -d ' ' -f 2 | cut -d '	' -f 2)"
            shift
            ;;
          -*)
            break
            ;;
          *)
            prompt -e "ERROR: Unrecognized logo variant '$1'."
            prompt -i "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      prompt -e "ERROR: Unrecognized installation option '$1'."
      prompt -i "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

if [[ "${#screens[@]}" -eq 0 ]] ; then
  screens=("${SCREEN_VARIANTS[0]}")
fi

if [[ "${#themes[@]}" -eq 0 ]] ; then
  themes=("${THEME_VARIANTS[0]}")
fi

if [[ "${#types[@]}" -eq 0 ]] ; then
  types=("${TYPE_VARIANTS[0]}")
fi

if [[ "${#sides[@]}" -eq 0 ]] ; then
  sides=("${SIDE_VARIANTS[0]}")
fi

if [[ "${#colors[@]}" -eq 0 ]] ; then
  colors=("${COLOR_VARIANTS[0]}")
fi

for theme in "${themes[@]}"; do
  for type in "${types[@]}"; do
    for side in "${sides[@]}"; do
      for color in "${colors[@]}"; do
        for screen in "${screens[@]}"; do
          generate "${dest:-$REO_DIR}" "${theme}" "${type}" "${side}" "${color}" "${screen}"
        done
      done
    done
  done
done

exit 0
