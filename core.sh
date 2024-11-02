
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
  prompt -w "Checking themes directory ...\n"

  [[ -d "${THEME_DIR}" ]] && rm -rf "${THEME_DIR}"
  mkdir -p "${THEME_DIR}"

  # Copy theme
  prompt -i "Install in ${THEME_DIR} ...\n"

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

  prompt -i "Install ${logoicon} logo.\n"
  if [[ -f "${REO_DIR}/assets/assets-other/other-${screen}/${logoicon}.png" ]]; then
    cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-other/other-${screen}/${logoicon}.png" "${THEME_DIR}/logo.png"
  else
    prompt -w "\n Did not find ${logoicon} logo ! install default one."
    cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-other/other-${screen}/Default.png" "${THEME_DIR}/logo.png"
  fi

  # Use custom background.jpg as grub background image
  if [[ -f "${REO_DIR}/background.jpg" ]]; then
    prompt -w "Using custom background.jpg as grub background image...\n"
    cp -a --no-preserve=ownership "${REO_DIR}/background.jpg" "${THEME_DIR}/background.jpg"
    convert -auto-orient "${THEME_DIR}/background.jpg" "${THEME_DIR}/background.jpg"
  fi
}

install() {
  local theme="${1}"
  local type="${2}"
  local side="${3}"
  local color="${4}"
  local screen="${5}"

  local THEME_DIR="${GRUB_DIR}/${THEME_NAME}-${theme}-${type}-${side}-${color}"

  # Check for root access and proceed if it is present
  if [[ "$UID" -eq "$ROOT_UID" ]]; then
    copy_files

    # Set theme
    prompt -i "Setting ${THEME_NAME}-${theme}-${type}-${side}-${color} as default...\n"

    # Backup grub config
    if [[ -f /etc/default/grub.bak ]]; then
      prompt -w "File '/etc/default/grub.bak' already exists!\n"
    else
      cp -an /etc/default/grub /etc/default/grub.bak
    fi

    # Fedora workaround to fix the missing unicode.pf2 file (tested on fedora 34): https://bugzilla.redhat.com/show_bug.cgi?id=1739762
    # This occurs when we add a theme on grub2 with Fedora.
    if has_command dnf; then
      if [[ -f "/boot/grub2/fonts/unicode.pf2" ]]; then
        if grep "GRUB_FONT=" /etc/default/grub 2>&1 >/dev/null; then
          #Replace GRUB_FONT
          sed -i "s|.*GRUB_FONT=.*|GRUB_FONT=/boot/grub2/fonts/unicode.pf2|" /etc/default/grub
        else
          #Append GRUB_FONT
          echo "GRUB_FONT=/boot/grub2/fonts/unicode.pf2" >> /etc/default/grub
        fi
      elif [[ -f "/boot/efi/EFI/fedora/fonts/unicode.pf2" ]]; then
        if grep "GRUB_FONT=" /etc/default/grub 2>&1 >/dev/null; then
          #Replace GRUB_FONT
          sed -i "s|.*GRUB_FONT=.*|GRUB_FONT=/boot/efi/EFI/fedora/fonts/unicode.pf2|" /etc/default/grub
        else
          #Append GRUB_FONT
          echo "GRUB_FONT=/boot/efi/EFI/fedora/fonts/unicode.pf2" >> /etc/default/grub
        fi
      fi
    fi

    if grep "GRUB_THEME=" /etc/default/grub 2>&1 >/dev/null; then
      #Replace GRUB_THEME
      sed -i "s|.*GRUB_THEME=.*|GRUB_THEME=\"${THEME_DIR}/theme.txt\"|" /etc/default/grub
    else
      #Append GRUB_THEME
      echo "GRUB_THEME=\"${THEME_DIR}/theme.txt\"" >> /etc/default/grub
    fi

    if grep "GRUB_BACKGROUND=" /etc/default/grub 2>&1 >/dev/null; then
      #Replace GRUB_BACKGROUND
      sed -i "s|.*GRUB_BACKGROUND=.*|GRUB_BACKGROUND=\"${THEME_DIR}/background.jpg\"|" /etc/default/grub
    else
      #Append GRUB_BACKGROUND
      echo "GRUB_BACKGROUND=\"${THEME_DIR}/background.jpg\"" >> /etc/default/grub
    fi

    prompt -i "Setting ${screen} resolution as 'GRUB_GFXMODE'...\n"

    # Make sure the right resolution for grub is set
    if [[ ${screen} == '1080p' ]]; then
      gfxmode="GRUB_GFXMODE=1920x1080,auto"
    elif [[ ${screen} == '4k' ]]; then
      gfxmode="GRUB_GFXMODE=3840x2160,auto"
    elif [[ ${screen} == '2k' ]]; then
      gfxmode="GRUB_GFXMODE=2560x1440,auto"
    fi

    if grep "GRUB_GFXMODE=" /etc/default/grub 2>&1 >/dev/null; then
      #Replace GRUB_GFXMODE
      sed -i "s|.*GRUB_GFXMODE=.*|${gfxmode}|" /etc/default/grub
    else
      #Append GRUB_GFXMODE
      echo "${gfxmode}" >> /etc/default/grub
    fi

    if grep "GRUB_TERMINAL=console" /etc/default/grub 2>&1 >/dev/null || grep "GRUB_TERMINAL=\"console\"" /etc/default/grub 2>&1 >/dev/null; then
      #Replace GRUB_TERMINAL
      sed -i "s|.*GRUB_TERMINAL=.*|#GRUB_TERMINAL=console|" /etc/default/grub
    fi

    if grep "GRUB_TERMINAL_OUTPUT=console" /etc/default/grub 2>&1 >/dev/null || grep "GRUB_TERMINAL_OUTPUT=\"console\"" /etc/default/grub 2>&1 >/dev/null; then
      #Replace GRUB_TERMINAL_OUTPUT
      sed -i "s|.*GRUB_TERMINAL_OUTPUT=.*|#GRUB_TERMINAL_OUTPUT=console|" /etc/default/grub
    fi

    # For Kali linux
    if [[ -f "/etc/default/grub.d/kali-themes.cfg" && ! -f "/etc/default/grub.d/kali-themes.cfg.bak" ]]; then
      cp -an /etc/default/grub.d/kali-themes.cfg /etc/default/grub.d/kali-themes.cfg.bak
      sed -i "s|.*GRUB_GFXMODE=.*|${gfxmode}|" /etc/default/grub.d/kali-themes.cfg
      sed -i "s|.*GRUB_THEME=.*|GRUB_THEME=\"${THEME_DIR}/theme.txt\"|" /etc/default/grub.d/kali-themes.cfg
    fi

    # Update grub config
    prompt -i "Updating grub config...\n"
    updating_grub
    prompt -w "\n * At the next restart of your computer you will see your new Grub theme\n"

  #Check if password is cached (if cache timestamp has not expired yet)
  elif sudo -n true 2> /dev/null && echo; then
    if [[ "${install_boot}" == 'true' ]]; then
      sudo "$0" -t ${theme} -p ${type} -i ${side} -c ${color} -s ${screen} -l ${logo} -b
    else
      sudo "$0" -t ${theme} -p ${type} -i ${side} -c ${color} -s ${screen} -l ${logo}
    fi
  else
    #Ask for password
    if [[ -n ${tui_root_login} ]] ; then
      if [[ -n "${theme}" && -n "${screen}" ]]; then
        if [[ "${install_boot}" == 'true' ]]; then
          sudo -S $0 -t ${theme} -p ${type} -i ${side} -c ${color} -s ${screen} -l ${logo} -b <<< ${tui_root_login}
        else
          sudo -S $0 -t ${theme} -p ${type} -i ${side} -c ${color} -s ${screen} -l ${logo} <<< ${tui_root_login}
        fi
      fi
    else
      prompt -e "\n [ Error! ] -> Run me as root! "
      read -r -p " [ Trusted ] Specify the root password : " -t ${MAX_DELAY} -s
      if sudo -S echo <<< $REPLY 2> /dev/null && echo; then
        #Correct password, use with sudo's stdin
        if [[ "${install_boot}" == 'true' ]]; then
          sudo -S "$0" -t ${theme} -p ${type} -i ${side} -c ${color} -s ${screen} -l ${logo} -b <<< ${REPLY}
        else
          sudo -S "$0" -t ${theme} -p ${type} -i ${side} -c ${color} -s ${screen} -l ${logo} <<< ${REPLY}
        fi
      else
        #block for 3 seconds before allowing another attempt
        sleep 3
        prompt -e "\n [ Error! ] -> Incorrect password!\n"
        exit 1
      fi
    fi
  fi
}

run_dialog() {
  if [[ -x /usr/bin/dialog ]]; then
    if [[ "$UID" -ne "$ROOT_UID"  ]]; then
      #Check if password is cached (if cache timestamp not expired yet)
      if sudo -n true 2> /dev/null && echo; then
        #No need to ask for password
        sudo $0
      else
        #Ask for password
        tui_root_login=$(dialog --backtitle ${Project_Name} \
        --title  "ROOT LOGIN" \
        --insecure \
        --passwordbox  "require root permission" 8 50 \
        --output-fd 1 )

        if sudo -S echo <<< $tui_root_login 2> /dev/null && echo; then
          #Correct password, use with sudo's stdin
          sudo -S "$0" <<< $tui_root_login
        else
          #block for 3 seconds before allowing another attempt
          sleep 3
          # clear
          echo -e '\0033\0143'
          prompt -e "\n [ Error! ] -> Incorrect password!\n"
          exit 1
        fi
      fi
    fi

    tui=$(dialog --backtitle ${Project_Name} \
    --radiolist "Choose your Grub theme background picture : " 15 40 5 \
      1 "Forest" on \
      2 "Mojave" off \
      3 "Mountain" off \
      4 "Wave" off --output-fd 1 )
      case "$tui" in
        1) theme="forest"     ;;
        2) theme="mojave"     ;;
        3) theme="mountain"   ;;
        4) theme="wave"       ;;
        *) operation_canceled ;;
     esac

    tui=$(dialog --backtitle ${Project_Name} \
    --radiolist "Choose your Grub theme style : " 15 40 5 \
      1 "Window" on \
      2 "Float" off \
      3 "Sharp" off \
      4 "blur" off --output-fd 1 )
      case "$tui" in
        1) type="window"      ;;
        2) type="float"       ;;
        3) type="sharp"       ;;
        4) type="blur"        ;;
        *) operation_canceled ;;
     esac

    tui=$(dialog --backtitle ${Project_Name} \
    --radiolist "Choose your Grub theme picture side : " 15 40 5 \
      1 "Left" on \
      2 "Right" off --output-fd 1 )
      case "$tui" in
        1) side="left"      ;;
        2) side="right"       ;;
        *) operation_canceled ;;
     esac

    tui=$(dialog --backtitle ${Project_Name} \
    --radiolist "Choose your Grub theme background color variant : " 15 40 5 \
      1 "Dark" on \
      3 "Light" off --output-fd 1 )
      case "$tui" in
        1) color="dark"       ;;
        2) color="light"      ;;
        *) operation_canceled ;;
     esac

    tui=$(dialog --backtitle ${Project_Name} \
    --radiolist "Choose your Grub theme logo variant : " 15 40 5 \
      1 "None" on \
      2 "Default" off \
      3 "System" off --output-fd 1 )
      case "$tui" in
        1) logoicon="Empty"       ;;
        2) logoicon="Default" ;;
        3) logoicon="$(lsb_release -i | cut -d ' ' -f 2 | cut -d '	' -f 2)" ;;
        *) operation_canceled ;;
     esac

    tui=$(dialog --backtitle ${Project_Name} \
    --radiolist "Choose your Display Resolution : " 15 40 5 \
      1 "1080p (1920x1080)" on \
      2 "2k (2560x1440)" off \
      3 "4k (3840x2160)" off --output-fd 1 )
      case "$tui" in
        1) screen="1080p"       ;;
        2) screen="2k"          ;;
        3) screen="4k"          ;;
        *) operation_canceled   ;;
     esac

     # clear
     echo -e '\0033\0143'
  fi
}

operation_canceled() {
  prompt -i "\n Operation canceled by user, Bye!"
  exit 1
}

updating_grub() {
  if has_command update-grub; then
    update-grub
  elif has_command grub-mkconfig; then
    grub-mkconfig -o /boot/grub/grub.cfg
  # Check for OpenSuse (regular or microOS)
  elif has_command zypper || has_command transactional-update; then
    grub2-mkconfig -o /boot/grub2/grub.cfg
  # Check for Fedora (regular or Atomic)
  elif has_command dnf || has_command rpm-ostree; then
    # Check for BIOS
    if [[ -f /boot/grub2/grub.cfg ]]; then
      prompt -s "Find config file on /boot/grub2/grub.cfg ...\n"
      grub2-mkconfig -o /boot/grub2/grub.cfg
    # Check for UEFI
    elif [[ -f /boot/efi/EFI/fedora/grub.cfg ]]; then
      prompt -s "Find config file on /boot/efi/EFI/fedora/grub.cfg ...\n"
      grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
    fi
  fi

  # Success message
  prompt -s "\n * All done!"
}

remove() {
  local theme="${1}"
  local type="${2}"
  local side="${3}"
  local color="${4}"

  local THEME_DIR="${GRUB_DIR}/${THEME_NAME}-${theme}-${type}-${side}-${color}"

  # Check for root access and proceed if it is present
  if [[ "$UID" -eq "$ROOT_UID" ]]; then
    prompt -i "Checking for the existence of themes directory..."
    if [[ -d "${THEME_DIR}" ]]; then
      prompt -i "\n Find installed theme: '${THEME_DIR}'..."
      rm -rf "${THEME_DIR}"
      prompt -w "\n Removed: '${THEME_DIR}'..."
    elif [[ -d "/boot/grub/themes/${THEME_NAME}-${theme}-${type}-${side}-${color}" ]]; then
      prompt -i "\n Find installed theme: '/boot/grub/themes/${THEME_NAME}-${theme}-${type}-${side}-${color}'..."
      rm -rf "/boot/grub/themes/${THEME_NAME}-${theme}-${type}-${side}-${color}"
      prompt -w "\n Removed: '/boot/grub/themes/${THEME_NAME}-${theme}-${type}-${side}-${color}'..."
    elif [[ -d "/boot/grub2/themes/${THEME_NAME}-${theme}-${type}-${side}-${color}" ]]; then
      prompt -i "\n Find installed theme: '/boot/grub2/themes/${THEME_NAME}-${theme}-${type}-${side}-${color}'..."
      rm -rf "/boot/grub2/themes/${THEME_NAME}-${theme}-${type}-${side}-${color}"
      prompt -w "\n Removed: '/boot/grub2/themes/${THEME_NAME}-${theme}-${type}-${side}-${color}'..."
    else
      prompt -e "\n Specified ${THEME_NAME}-${theme}-${type}-${side}-${color} theme does not exist!"
      exit 0
    fi

    local grub_config_location=""

    if [[ -f "/etc/default/grub" ]]; then
      grub_config_location="/etc/default/grub"
    elif [[ -f "/etc/default/grub.d/kali-themes.cfg" ]]; then
      grub_config_location="/etc/default/grub.d/kali-themes.cfg"
    else
      prompt -e "\n Cannot find grub config file in default locations!"
      prompt -w "\n Please inform the developers by opening an issue on github."
      prompt -i "\n Exiting..."
      exit 1
    fi

    local current_theme="" # Declaration and assignment should be done seperately ==> https://github.com/koalaman/shellcheck/wiki/SC2155

    current_theme="$(grep 'GRUB_THEME=' $grub_config_location | grep -v \#)"

    if [[ -n "$current_theme" ]]; then
      # Backup with --in-place option to grub.bak within the same directory; then remove the current theme.
      sed --in-place='.bak' "s|$current_theme|#GRUB_THEME=|" "$grub_config_location"

      if [[ -f "$grub_config_location".back ]]; then
        rm -rf "$grub_config_location".back
      fi

      # Update grub config
      prompt -i "\n Resetting grub theme...\n"
      updating_grub
    else
      prompt -e "\n No active theme found."
      prompt -i "\n Exiting..."
      exit 1
    fi
  else
    #Check if password is cached (if cache timestamp not expired yet)
    if sudo -n true 2> /dev/null && echo; then
      #No need to ask for password
      sudo "$0" -t ${theme} -p ${type} -i ${side} -c ${color} "${PROG_ARGS[@]}"
    else
      #Ask for password
      prompt -e "\n [ Error! ] -> Run me as root! "
      read -r -p " [ Trusted ] Specify the root password : " -t ${MAX_DELAY} -s #when using "read" command, "-r" option must be supplied ==> https://github.com/koalaman/shellcheck/wiki/SC2162

      if sudo -S echo <<< $REPLY 2> /dev/null && echo; then
        #Correct password, use with sudo's stdin
        sudo -S "$0" -t ${theme} -p ${type} -i ${side} -c ${color} "${PROG_ARGS[@]}" <<< $REPLY
      else
        #block for 3 seconds before allowing another attempt
        sleep 3
        echo -e '\0033\0143'
        prompt -e "\n [ Error! ] -> Incorrect password!\n"
        exit 1
      fi
    fi
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

