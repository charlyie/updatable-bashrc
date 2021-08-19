#!/bin/bash
# Updatable-Bashrc
#
# The MIT License (MIT)
# Copyright (c) 2017-2021 Charles Bourgeaux <charles@resmush.it> and contributors
# You are not obligated to bundle the LICENSE file with your projects as long
# as you leave these references intact in the header comments of your source files.

UBRC_VERSION="1.1.0"
UBRC_VERSION_BUILD="20210819"
UBRC_REQUIRED_PACKAGES=( "curl" "jq" )
UBRC_UPDATE_LOCKFILE="/tmp/.updatable-bashrc.update"
UBRC_APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
UBRC_ALIASES_APPEND="${UBRC_APP_DIR}/.aliases.ubrc"
UBRC_FUNCTIONS_APPEND="${UBRC_APP_DIR}/.functions.ubrc"
UBRC_CUSTOM_APPEND="${UBRC_APP_DIR}/.custom.bashrc"
UBRC_APP="${BASH_SOURCE[0]}"


# Public function : display updatable-bashrc version
ubrc_version(){
    if [[ $1 == "short" ]]; then 
        echo $UBRC_VERSION
    else
        printf "Updatable-Bashrc v.$UBRC_VERSION ($UBRC_VERSION_BUILD). \n(c) Charles Bourgeaux <charles@resmush.it> 2017-2021\n"
    fi
}

# Internal function : write text with color
__ubrc_display(){
    WHITE="\033[0;97m"
    RED="\033[0;31m"
    GREEN="\033[0;32m"
    NC="\033[0m" # No Color
    BOLD=$(tput bold)
    NORMAL=$(tput sgr0)

    COLOR_OPEN_TAG=''
    COLOR_CLOSE_TAG=$NORMAL
    if [[ $2 == "green" ]]; then 
        COLOR_OPEN_TAG=$GREEN
    elif [[ $2 == "red" ]]; then
        COLOR_OPEN_TAG=$RED
    elif [[ $2 == "white" ]]; then
        COLOR_OPEN_TAG=$WHITE
    elif [[ $2 == "standard" ]]; then
        COLOR_OPEN_TAG=$NORMAL
    fi
    
    STROUTPUT="${GREEN}${BOLD}[${NORMAL}Updatable-Bashrc${GREEN}${BOLD}]${NORMAL} $1"
    if [[ $3 == "noprefix" ]]; then
        STROUTPUT=$1
    fi 
    printf "${COLOR_OPEN_TAG}$STROUTPUT ${COLOR_CLOSE_TAG}\n"
}


# Internal function : requirement check
__ubrc_can_boot() {
    for x in ${UBRC_REQUIRED_PACKAGES[@]}
    do
        if ! which $x > /dev/null; then
            return 0
        fi
    done
    return 1
}

# Internal function : check required packages and try to install them
__ubrc_prerequisites() {
    for x in "${UBRC_REQUIRED_PACKAGES[@]}"
    do
        if ! which "$x" > /dev/null; then
          __ubrc_display "Missing package $x. " red
          echo -e "Try to install it ? (y/n) \c"
          read -r
          if [[ "$REPLY" == "y" ]]; then
            # Package installation on MacOS platform
            if [ "$(uname)" == "Darwin" ]; then
                __ubrc_display "Trying to install the package using homebrew..."
                brew install "$x"      
            elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
                if [[ $(id -u) -ne 0 ]]; then
                  __ubrc_display "Package installation needs ROOT privileges. Please log as root or use sudo."
                  exit 0
              fi

              if [ -n "$(command -v yum)" ]; then
                sudo yum update
                sudo yum install "$x"
                if ! which sudo > /dev/null || ! which apt-get > /dev/null; then
                  __ubrc_display "Cannot install package '$x' automatically. Please install it manually."
                  exit 0
              fi
          elif [ -n "$(command -v apt-get)" ]; then
            sudo apt-get -qq update
            sudo apt-get -y -qq install "$x"
            if ! which sudo > /dev/null || ! which apt-get > /dev/null; then
              __ubrc_display "Cannot install package '$x' automatically. Please install it manually."
              exit 0
          fi
      else
        __ubrc_display "Unsupported Linux package manager. Try to install the package $x manually."
        exit 0
    fi
else
    __ubrc_display "Unsupported platform. Try to install the package $x manually."
    exit 0
fi

else
    __ubrc_display "Some package are missing. Try to install them before."
    exit 0
fi
fi
done
}

# Internal function : handles update lock
__ubrc_update_lock(){
    if [[ __ubrc_can_boot == 0 ]]; then
        return
    fi
    if [ -f "${UBRC_UPDATE_LOCKFILE}" ]; then
        if [ -w $UBRC_UPDATE_LOCKFILE ]; then
            echo "$1" > $UBRC_UPDATE_LOCKFILE
        else
            __ubrc_display "Cannot write temporary file $UBRC_UPDATE_LOCKFILE, please check if this file is writeable" red
        fi
    else
        echo "$1" > $UBRC_UPDATE_LOCKFILE
    fi
}

# Public function : check for update from remote repository
ubrc_check_update(){
    if [[ __ubrc_can_boot == 0 ]]; then
        return
    fi

    if [[ "$1" == "checklock" ]]; then 
            # Perform update verification once a day
            if [ -f ${UBRC_UPDATE_LOCKFILE} ]; then
                _UBRC_UPDATE_LOCKFILE_VALUE=$(cat $UBRC_UPDATE_LOCKFILE)

                if [[ $_UBRC_UPDATE_LOCKFILE_VALUE == "false" ]]; then
                    if [[ $(find "${UBRC_UPDATE_LOCKFILE}" -mtime -1 -print) ]]; then
                        return
                    fi
                else
                    __ubrc_display "An update is available. Launching upgrade..." blue
                    __ubrc_do_upgrade
                    return
                fi
            fi
        fi

        __ubrc_display "Checking for update..." standard notime
        _REQUEST_OUTPUT=$(curl --silent "https://api.github.com/repos/charlyie/updatable-bashrc/tags")
        _REMOTE_VERSION=$(echo ${_REQUEST_OUTPUT} | jq -r '.[0].name')
        _TARBALL=$(echo ${_REQUEST_OUTPUT} | jq -r '.[0].tarball_url')

        if [[ $_REMOTE_VERSION == "${UBRC_VERSION}" ]]; then
            __ubrc_display "No update required (remote version is : ${_REMOTE_VERSION})" green
            __ubrc_update_lock "false"
        else
            __ubrc_display "An update is available. Launching upgrade..." blue
            __ubrc_do_upgrade
            __ubrc_update_lock "true"
        fi
    }

# Internal function : perform application upgrade
__ubrc_do_upgrade(){
    _REQUEST_OUTPUT=`curl --silent "https://api.github.com/repos/charlyie/updatable-bashrc/tags"`
    _REMOTE_VERSION=`echo ${_REQUEST_OUTPUT} | jq -r '.[0].name'`
    _TARBALL=`echo ${_REQUEST_OUTPUT} | jq -r '.[0].tarball_url'`

    if [[ $_REQUEST_OUTPUT == "${UBRC_VERSION}" ]]; then
        __ubrc_display "No update required (remote version is : ${_REMOTE_VERSION})" green
    else
        __ubrc_display "> Local version  : ${UBRC_VERSION}" standard notime
        __ubrc_display "> Remote version : ${_REMOTE_VERSION}" standard notime

        if [[ "${UBRC_VERSION}" !=  "${_REMOTE_VERSION}" ]]; then
            __ubrc_display "An update is available. Launching upgrade..." blue notime
            if [ ! -w "$UBRC_APP" ]; then
                __ubrc_display "Current executable not writable. Please run with sudo." red
                exit 0
            fi

            __ubrc_display "> Downloading from ${_TARBALL}..." standard notime
            if [ -d "/tmp/updatable-bashrc-last-release" ]; then
                rm -rf /tmp/updatable-bashrc-last-release
            fi
            mkdir -p /tmp/updatable-bashrc-last-release
            curl -L "${_TARBALL}" --output /tmp/updatable-bashrc-last-release.tar.gz --silent
            __ubrc_display "> Extracting tarball..." standard notime
            tar xf /tmp/updatable-bashrc-last-release.tar.gz -C /tmp/updatable-bashrc-last-release
            __ubrc_display "> Replacing executable..." standard notime
            cp /tmp/updatable-bashrc-last-release/*/.bashrc "$UBRC_APP"
            cp /tmp/updatable-bashrc-last-release/*/.aliases.ubrc "$UBRC_ALIASES_APPEND"
            cp /tmp/updatable-bashrc-last-release/*/.functions.ubrc "$UBRC_FUNCTIONS_APPEND"
            if [[ ! -f "$UBRC_CUSTOM_APPEND" ]]; then
                cp /tmp/updatable-bashrc-last-release/*/.custom.bashrc "$UBRC_CUSTOM_APPEND"
            fi
            
            rm -f $UBRC_UPDATE_LOCKFILE
            source "$UBRC_APP"
            __ubrc_display "> New installed version is :" green notime
            ubrc_version short
        else
            __ubrc_display "No update available" blue notime
        fi
    fi
}

__ubrc_display "Updatable-Bashrc configuration loaded."

#Run System requirements check
__ubrc_prerequisites

#Run update check if needed
ubrc_check_update checklock



## Content of .bashrc

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of 'ignorespace'.
HISTCONTROL=$HISTCONTROL${HISTCONTROL+:}ignoredups
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    CURRENTUSER=$(whoami)
    if [ "$CURRENTUSER" = "root" ]; then
      PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;36m\]\w\[\033[00m\]\[\033[01;32m\]$\[\033[00m\] '
  else
      PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;36m\]\w\[\033[00m\]\[\033[01;32m\]$\[\033[00m\] '
  fi
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
    xterm*|rxvt*)
PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
;;
*)
;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=always'
fi


# Default Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi


# Aliases proposed by Updatable-Bashrc app
if [[ -f "$UBRC_ALIASES_APPEND" ]]; then
    source $UBRC_ALIASES_APPEND
fi

# Functions proposed by Updatable-Bashrc app
if [[ -f "$UBRC_FUNCTIONS_APPEND" ]]; then
    source $UBRC_FUNCTIONS_APPEND
fi

# User/environment custom functions. Won't be overrided during upgrades.
if [[ -f "$UBRC_CUSTOM_APPEND" ]]; then
    source $UBRC_CUSTOM_APPEND
fi