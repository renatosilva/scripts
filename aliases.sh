# Aliases 2016.1.21
# Copyright (c) 2012-2014, 2016 Renato Silva
## GNU GPLv2 licensed

alias cat='vimcat'
alias whence='type -a'
alias greper='grep -rnE'
alias mark='grep -C 1000000 -iE'
alias pacman='pacman --color auto'
alias ls='ls --color=auto --show-control-chars'
alias grep='grep --color=auto'

export PATH="${PATH/:\/bin:\/usr\/bin:/:\/bin:}"
export PATH="${PATH/:\/opt\/bin:\/usr\/bin:/:\/opt\/bin:}"
export PATH="${PATH/:\/c\/MSYS2\/usr\/bin/}"
export RUBYLIB="${RUBYLIB}:/usr/local/bin"
export CYGWIN='winsymlinks:native'
export MSYS='winsymlinks:native'
export LESSHISTFILE='-'
export PAGER='vimpager'

# Prompt
msys2_prompt_color="${MSYSCON:+38;05;129m}"
msys2_prompt_color="${msys2_prompt_color:-1;35m}"
export PS1_MSYS2="\[\e]0;${MSYSTEM}\a\e[${msys2_prompt_color}\]\W\[\e[0m\] \$ "
export PS1_MSYS1="\[\e]0;${MSYSTEM} \007\e[38;05;117m\]\W\[\e[0m\] \$ "
export PS1_CYGWIN="\[\e]0;Cygwin\a\e[38;05;35m\]\W\[\e[0m\] \$ "

ssh()      { ssh-auth; command ssh "$@"; }
scp()      { ssh-auth; command scp "$@"; }
diff()     { [[ -t 1 ]] && command colordiff "$@" || command diff "$@"; }
bzr()      { [[ "${1}" = diff ]] && command bzr "$@" | diff || command bzr "$@"; }
git()      { [[ "${1}" = diff ]] && command git "$@" | diff || command git "$@"; }
bzrsav()   { find -name '*.~1~'  -exec bash -c "mv -v '{}' \$(sed 's/\.~1~/.${1}/' <<<'{}')" \;; }
bzrres()   { find -name "*.${1}" -exec bash -c "mv -v '{}' \$(sed 's/\.${1}$//'    <<<'{}')" \;; }
wingrep()  { { command grep "$@" 2>&1 >&3 | command grep -v 'Permission denied'; } 3>&1; }
winfind()  { { command find "$@" 2>&1 >&3 | command grep -v 'Permission denied'; } 3>&1; }
vpaste()   { test -f "${1}" && local file="${1}" || local parameters="${1}"
             echo $(curl --silent --form "text=<${file:--}" "http://vpaste.net/?${parameters:-$2}"); }
ssh-auth() { [[ -z $(ps | grep ssh-agent) ]] && echo $(ssh-agent) > /tmp/ssh-agent-data.sh
             [[ -z $SSH_AGENT_PID ]] && source /tmp/ssh-agent-data.sh > /dev/null
             [[ -z $(ssh-add -l | grep "/home/$(whoami)/.ssh/id_rsa") ]] && ssh-add; }
