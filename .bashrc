#!/bin/bash
BASHRC_VERSION="0.1.0"
BUILD_DATE="20210818"
REQUIRED_PACKAGES=( "curl" "jq" )
UPDATE_LOCKFILE="/tmp/.updatable-bashrc.update"
APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
BASHRC_APPEND="${APP_DIR}/.custom.bashrc"
BASHRC_APP="${BASH_SOURCE[0]}"



# Internal function : provide color for text
cli_output(){
        COLOR_OPEN_TAG=''
        COLOR_CLOSE_TAG=$NC
        if [[ $2 == "green" ]]; 
        then 
                COLOR_OPEN_TAG=$GREEN
        elif [[ $2 == "red" ]]; 
        then
                COLOR_OPEN_TAG=$RED
        elif [[ $2 == "blue" ]]; 
        then
                COLOR_OPEN_TAG=$LBLUE
        elif [[ $2 == "standard" ]]; 
        then
                COLOR_OPEN_TAG=$NC
        fi
        printf "${COLOR_OPEN_TAG}$1 ${COLOR_CLOSE_TAG}\n"
}
# Internal function : requirement check
bashrc_can_boot() {
        for x in ${REQUIRED_PACKAGES[@]}
        do
                if ! which $x > /dev/null; then
                        return 0
                fi
        done
        return 1
}

# Check required packages and try to install them
for x in ${REQUIRED_PACKAGES[@]}
do
if ! which $x > /dev/null; 
then
  cli_output "Missing package $x. " red
  echo -e "Try to install it ? (y/n) \c"
  read
  if [[ "$REPLY" == "y" ]]; 
  then
        # Package installation on MacOS platform
        if [ "$(uname)" == "Darwin" ]; 
        then
            cli_output "Trying to install the package using homebrew..."
            brew install $x       
        elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; 
        then
                if [[ `id -u` -ne 0 ]]; 
                then
                  cli_output "Package installation needs ROOT privileges. Please log as root or use sudo."
                  exit 0
                fi

                if [ -n "$(command -v yum)" ]; 
                then
                        sudo yum update
                        sudo yum install $x
                        if ! which sudo > /dev/null || ! which apt-get > /dev/null; 
                        then
                      cli_output "Cannot install package '$x' automatically. Please install it manually."
                      exit 0
                    fi
                elif [ -n "$(command -v apt-get)" ]; 
                then
                        sudo apt-get -qq update
                        sudo apt-get -y -qq install $x 
                        if ! which sudo > /dev/null || ! which apt-get > /dev/null; 
                        then
                      cli_output "Cannot install package '$x' automatically. Please install it manually."
                      exit 0
                    fi
                else
                        cli_output "Unsupported Linux package manager. Try to install the package $x manually."
                        exit 0
                fi
        else
            cli_output "Unsupported platform. Try to install the package $x manually."
                exit 0
        fi
    
  else
    cli_output "Some package are missing. Try to install them before."
    exit 0
  fi
fi
done


# Internal function for lock
lockfile_update(){
        if [[ !bashrc_can_boot ]]; then
                return
        fi
        if [ -f "${UPDATE_LOCKFILE}" ]; then
                if [ -w $UPDATE_LOCKFILE ]; then
                        echo "$1" > $UPDATE_LOCKFILE
                else
                        cli_output "Cannot write temporary file $UPDATE_LOCKFILE, please check if this file is writeable" red
                fi
        else
                echo "$1" > $UPDATE_LOCKFILE
        fi
}

# Internal function : check for update from remote repository
check_update(){
        if [[ bashrc_can_boot == 0 ]]; then
                return
        fi

        # Perform update verification once a day
        if [ -f ${UPDATE_LOCKFILE} ]; then
                _UPDATE_LOCKFILE_VALUE=`cat $UPDATE_LOCKFILE`

                if [[ $_UPDATE_LOCKFILE_VALUE == "false" ]]; then
                        if [[ $(find "${UPDATE_LOCKFILE}" -mtime -1 -print) ]]; then
                                return
                        fi
                else
                        cli_output "An update is available. Launching upgrade..." blue
                        do_update
                        return
                fi
        fi

        cli_output "Checking for update..." standard notime
        _REQUEST_OUTPUT=`curl --silent "https://api.github.com/repos/charlyie/updatable-bashrc/tags"`
        _REMOTE_VERSION=`echo ${_REQUEST_OUTPUT} | jq -r '.[0].name'`
        _TARBALL=`echo ${_REQUEST_OUTPUT} | jq -r '.[0].tarball_url'`
        return
        if [[ $_REMOTE_VERSION == "${BASHRC_VERSION}" ]]; then
                cli_output "No update required (remote version is : ${_REMOTE_VERSION})" green
                lockfile_update "false"
        else
                cli_output "An update is available. Launching upgrade..." blue
                do_update
                lockfile_update "true"
        fi
}

# Internal function : perform update
do_update(){
        _REQUEST_OUTPUT=`curl --silent "https://api.github.com/repos/charlyie/updatable-bashrc/tags"`
        _REMOTE_VERSION=`echo ${_REQUEST_OUTPUT} | jq -r '.[0].name'`
        _TARBALL=`echo ${_REQUEST_OUTPUT} | jq -r '.[0].tarball_url'`

        if [[ $_REQUEST_OUTPUT == "${BASHRC_VERSION}" ]]; then
                cli_output "No update required (remote version is : ${_REMOTE_VERSION})" green
        else
                cli_output "> Local version  : ${BASHRC_VERSION}" standard notime
                cli_output "> Remote version : ${_REMOTE_VERSION}" standard notime

                if [[ "${BASHRC_VERSION}" !=  "${_REMOTE_VERSION}" ]]; then
                        cli_output "An update is available. Launching upgrade..." blue notime
                        if [ ! -w "$BASHRC_APP" ]; then
                                cli_output "Current executable not writable. Please run with sudo." red
                                exit 0
                        fi

                        cli_output "> Downloading from ${_TARBALL}..." standard notime
                        if [ -d "/tmp/updatable-bashrc-last-release" ]; then
                                rm -rf /tmp/updatable-bashrc-last-release
                        fi
                        mkdir -p /tmp/updatable-bashrc-last-release
                        curl -L ${_TARBALL} --output /tmp/updatable-bashrc-last-release.tar.gz --silent
                        cli_output "> Extracting tarball..." standard notime
                        tar xf /tmp/updatable-bashrc-last-release.tar.gz -C /tmp/updatable-bashrc-last-release
                        cli_output "> Replacing executable..." standard notime
                        cp /tmp/updatable-bashrc-last-release/*/.bashrc $BASHRC_APP
                        rm -f $UPDATE_LOCKFILE
                        cli_output "> New installed version is :" green notime
                        $BASHRC_APP --version
                        exit 0
                else
                        cli_output "No update available" blue notime
                fi
        fi
}

check_update


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

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

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
    CURRENTUSER=`whoami`
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



# Alias definitions.
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


## FUNCTION
# no more cd ../../../
up(){
    local d=""
    limit=$1
    for ((i=1 ; i <= limit ; i++))
    do
        d=$d/..
        done
    d=$(echo $d | sed 's/^\///')
    if [ -z "$d" ]; then
        d=..
        fi
    cd $d
}

# do sudo, or sudo the last command if no argument given
s(){
    if [[ $# == 0 ]]; then
        sudo $(history -p '!!')
    else
        sudo "$@"
    fi
}

# cd into the last changed directory
cl(){
    last_dir="$(ls -Frt | grep '/$' | tail -n1)"
    if [ -d "$last_dir" ]; then
        cd "$last_dir"
        fi
}

# find <dir> <file name regexp> <file contents regexp>
ff(){
    find ./ -iname "$2" ;
}

fe(){
    find "$1" -iname "$2" -exec grep -H "$3" "{}" \;
}

getip(){
    /sbin/ifconfig ${1:-eth0} | awk '/inet addr/ {print $2}' | awk -F: '{print $2}';
}

cdl(){
    if [ -n "$1" ]; then
        builtin cd "$@" && ls -la --color=always
        else
        builtin cd ~ && ls -la --color=always
        fi
}

g(){
    grep "$1" ./ ;
}

if [[ -f "$BASHRC_APPEND" ]]; then
        source $BASHRC_APPEND
fi