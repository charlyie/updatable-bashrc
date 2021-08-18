# some more ls aliases
alias fw='cat /etc/init.d/firewall'
alias fwe='vi /etc/init.d/firewall'
alias fwr='/etc/init.d/firewall restart'
alias fws='/etc/init.d/firewall stop'
alias ls='ls -hF --color=always'  # add colors for filetype recognition
alias ll='ls -la --color=always'
alias la='ls -lA --color=always'
alias lla='ls -lA --color=always'
alias l='ls -CF --color=always'
alias lr='ls -lR --color=always'
alias lt='ls -ltr --color=always' # sort by date, most recent last
alias lx='ls -lXB --color=always' # sort by extension
alias lk='ls -lSr --color=always' # sort by size
alias lc='ls -lcr --color=always' # sort by change time
alias lu='ls -lur --color=always' # sort by access time
alias lm='ls -al | more'
alias ne='emacs'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias c='clear'
alias _='sudo'
alias q='exit'
alias h='history'
alias j='jobs -l'
alias ..='cd ..'
alias ba='emacs ~/.bashrc;source ~/.bashrc'
alias du='du -kh'
alias df='df -kTh'
alias stat="echo ' ' && uname -a && echo ' '&& uptime &&echo ' '&& df && echo ' '"
alias t='tail'
alias tf='tail -f'
alias mark='echo =================================================='
alias hg='history | grep --color=always'

## dir shortcuts
alias home='cd ~/'

# misstip
alias xs='cd'
alias vf='cd'
alias moer='more'
alias moew='more'
alias kk='ll'