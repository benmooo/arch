#!/bin/bash

USER_HOME=/home/$(whoami)

function configline() {
  local OLD_LINE_PATTERN=$1; shift
  local NEW_LINE=$1; shift
  local FILE=$1
  local NEW=$(echo "${NEW_LINE}" | sed 's/\//\\\//g')
  touch "${FILE}"
  sed -i '/'"${OLD_LINE_PATTERN}"'/{s/.*/'"${NEW}"'/;h};${x;/./{x;q100};x}' "${FILE}"
  if [[ $? -ne 100 ]] && [[ ${NEW_LINE} != '' ]]
  then
    echo "${NEW_LINE}" >> "${FILE}"
  fi
}
FUNC=$(declare -f configline)

# check prerequisites
function chk_prerequisites() {
    # check network connection
    ping -q -w1 -c1 baidu.com &> /dev/null
    if [ $? -ne 0 ]; then
        return 1
    fi

    # check if user is a sudo user
    username=$(whoami)
    getent group wheel | grep -q "\b${username}\b"
    if [ $? -ne 0 ]; then
        return 1
    fi
}

# install pkgs
function install_pkgs() {
    # fonts
    sudo pacman -S ttf-roboto ttf-roboto-mono noto-fonts-cjk ttf-dejavu otf-font-awesome

    # pkgs
	sudo pacman -S xorg-server xorg-xrandr lightdm lightdm-webkit2-greeter xmonad xmonad-contrib xmobar dmenu picom nitrogen termite 
}

function enable_lightdm() {
	sudo systemctl enable lightdm
}


# set virtual machine resolution when booting lightdm
function set_resolution() {
    # lightdm init script
    sudo bash -c "$FUNC; configline '*.display-setup-script=' 'display-setup-script=xrandr --mode 1920x1080' /etc/lightdm/lightdm.conf"
}


# customize lightdm
function config_lightdm() {
    # download lightdm theme
    curl -L -o ../glorious.tar.gz https://github.com/manilarome/lightdm-webkit2-theme-glorious/releases/download/v2.0.5/lightdm-webkit2-theme-glorious-2.0.5.tar.gz
    # extract 
    mkdir ../glorious
    tar -C ../glorious -xzvf ../glorious.tar.gz
    # move
    sudo cp -r ../glorious /usr/share/lightdm-webkit/themes/glorious
    # clean
    rm -rf ../glorious  ../glorious.tar.gz

    # set lightdm greeter session to webkit2
    sudo bash -c "$FUNC; configline '.*greeter-session=.*' 'greeter-session=lightdm-webkit2-greeter' /etc/lightdm/lightdm.conf"
    sudo bash -c "$FUNC; configline 'webkit_theme.*' 'webkit_theme = glorious' /etc/lightdm/lightdm-webkit2-greeter.conf"
    sudo bash -c "$FUNC; configline 'debug_mode.*' 'debug_mode = true' /etc/lightdm/lightdm-webkit2-greeter.conf"
}

function load_dotfiles() {
    cp -r ./migration/backups/dotfiles/.config $USER_HOME
    cp -r ./migration/backups/dotfiles/.xmonad $USER_HOME
    cp -r ./migration/backups/dotfiles/.face $USER_HOME
    username=$(whoami)
    sed -i -e "s/akatsuki/${username}/g" ../.xmonad/xmonad.hs
}


function main() {
    if [[ $1 == "chkPrerequisites" ]]
    then
        chk_prerequisites
    elif [[ $1 == "installPkgs" ]]
    then
        install_pkgs
    elif [[ $1 == "enableLightdm" ]]
    then
        enable_lightdm
    elif [[ $1 == "loadDotfiles" ]]
    then
       load_dotfiles 
    elif [[ $1 == "setResolution" ]]
    then
        set_resolution
    elif [[ $1 == "configLightdm" ]]
    then
        config_lightdm
    elif [[ $1 == "all" ]]
    then
        chk_prerequisites
        if [ $? -ne 0 ]; then
            return 1
        fi
        
        install_pkgs
        enable_lightdm
        load_dotfiles
        # set_resolution
        config_lightdm
    fi
}

main $1 $2 $3