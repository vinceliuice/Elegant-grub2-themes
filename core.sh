
readonly ROOT_UID=0
readonly Project_Name="GRUB2_ELEGANT_THEMES"
readonly MAX_DELAY=20                               # max delay for user to enter root password
tui_root_login=

THEME_NAME=Elegant
GRUB_DIR="/usr/share/grub/themes"
REO_DIR="$(cd $(dirname $0) && pwd)"

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
has_command() {
  command -v $1 &> /dev/null #with "&>", all output will be redirected.
}

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

install_program() {
  if has_command zypper; then
    zypper in "$@"
  elif has_command apt-get; then
    apt-get install "$@"
  elif has_command dnf; then
    dnf install -y "$@"
  elif has_command yum; then
    yum install "$@"
  elif has_command pacman; then
    pacman -S --noconfirm "$@"
  fi
}

install_dialog() {
  if [ ! "$(which dialog 2> /dev/null)" ]; then
    prompt -w "\n 'dialog' need to be installed for this shell"
    install_program "dialog"
  fi
}

dialog_installer() {
  if [[ ! -x /usr/bin/dialog ]];  then
    if [[ "$UID" -ne "$ROOT_UID" ]];  then
      #Check if password is cached (if cache timestamp not expired yet)

      if sudo -n true 2> /dev/null && echo; then
        #No need to ask for password
        exec sudo $0
      else
        #Ask for password
        prompt -e "\n [ Error! ] -> Run me as root! "
        read -r -p " [ Trusted ] Specify the root password : " -t ${MAX_DELAY} -s

        if sudo -S echo <<< $REPLY 2> /dev/null && echo; then
          #Correct password, use with sudo's stdin
          sudo $0 <<< $REPLY
        else
          #block for 3 seconds before allowing another attempt
          sleep 3
          prompt -e "\n [ Error! ] -> Incorrect password!\n"
          exit 1
        fi
      fi
    fi
    install_dialog
  fi
  run_dialog
  install "${theme}" "${type}" "${side}" "${color}" "${screen}"
  exit 1
}

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

