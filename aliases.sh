# Aliases 2016.5.6
# Copyright (C) 2012-2014, 2016 Renato Silva
# GNU GPLv2 licensed

alias whence='type -a'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias cat='vimcat'
alias make='colormake'
alias gcc='COLORMAKE_COMMAND=gcc colormake'
alias g++='COLORMAKE_COMMAND=g++ colormake'
alias clang='COLORMAKE_COMMAND=clang colormake'
alias search='grep -rnE'
alias highlight='grep -C1000000'
export RUBYLIB="${RUBYLIB}:/usr/local/bin"
export BZR_LOG='/dev/null'
export LESSHISTFILE='-'
export PAGER='vimpager'

if test -n "${WINDIR}"; then
    alias pacman='pacman --color=auto'
    alias attrib='winconv attrib'
    alias cmd='winconv cmd'
    alias ipconfig='winconv ipconfig'
    alias net='winconv net'
    alias ping='winconv ping'
    alias reg='winconv reg'
    alias schtasks='winconv schtasks'
    alias shutdown='winconv shutdown'
    alias taskkill='winconv taskkill'
    export LANG='en_US.UTF-8'
    export MSYS='winsymlinks:native'
    export CYGWIN='winsymlinks:native'
    export PATH="${PATH/:\/bin:\/usr\/bin:/:\/bin:}"
    export PATH="${PATH/:\/opt\/bin:\/usr\/bin:/:\/opt\/bin:}"
    export PATH="${PATH/:\/c\/MSYS2\/usr\/bin/}"
    export MSYS2_PS1_COLOR="${MSYSCON:+38;05;129m}"
    export MSYS2_PS1_COLOR="${MSYS2_PS1_COLOR:-1;35m}"
    export MSYS2_PS1="\[\e]0;${MSYSTEM}\a\e[${MSYS2_PS1_COLOR}\]\W\[\e[0m\] \$ "
    export MSYS1_PS1="\[\e]0;${MSYSTEM} \007\e[38;05;117m\]\W\[\e[0m\] \$ "
    export CYGWIN_PS1="\[\e]0;Cygwin\a\e[38;05;35m\]\W\[\e[0m\] \$ "
fi

ssh()      { ssh-auth; command ssh "${@}"; }
scp()      { ssh-auth; command scp "${@}"; }
bzr()      { command bzr "${1/#diff/cdiff}" "${@:2}"; }
git()      { GIT_PAGER=colordiff command git ${1/#diff/diff --no-color} "${@:2}"; }
diff()     { local prefix; test -t 1 && prefix='color'; command "${prefix}diff" "${@}"; }
stash()    { find -name "*.${2:-~1~}"  -exec bash -c "mv -v '{}' \$(sed 's/\.${2:-~1~}/.${1:-head}/' <<<'{}')" \;; }
spend()    { find -name "*.${1:-head}" -exec bash -c "mv -v '{}' \$(sed 's/\.${1:-head}$//' <<<'{}')" \;; }
vpaste()   { echo $(u='http://vpaste.net' f= q=; test -f "$1" && f="$1" || q="$1"; curl "-sFtext=<${f:--}" "$u/?${q:-$2}"); }
ssh-auth() { test -z "$(ps | grep ssh-agent)" && echo $(ssh-agent) > /tmp/ssh-agent-data.sh
             test -z "${SSH_AGENT_PID}" && source /tmp/ssh-agent-data.sh > /dev/null
             test -z "$(ssh-add -l | grep "/home/$(whoami)/.ssh/id_rsa")" && ssh-add; }
