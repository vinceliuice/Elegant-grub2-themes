#! /usr/bin/env bash

# Exit Immediately if a command fails
set -o errexit

readonly REPO_DIR="$(dirname "$(readlink -m "${0}")")"
source "${REPO_DIR}/core.sh"

usage() {
cat << EOF

Usage: $0 [OPTION]...

OPTIONS:
  -t, --theme     Background theme variant(s) [forest|mojave|mountain|wave] (default is forest)
  -p, --type      Theme style variant(s)      [window|float|sharp|blur] (default is window)
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

  copy_files

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
          blur)
            types+=("${TYPE_VARIANTS[3]}")
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
