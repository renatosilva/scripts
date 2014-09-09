# Aliases 2014.9.9
# Copyright (c) 2012-2014 Renato Silva
# GNU GPLv2 licensed

# Variables and aliases
export PAGER="vimpager"
alias cat="vimcat"
alias less="vimpager"
alias grepe="grep -rniE"
alias hl="grep -C 1000000"
alias hle="hl -iE"

# Colored diff
diff() {
    local prefix
    if [[ -t 1 ]]; then
        prefix="color"
    fi
    command "${prefix}diff" "$@"
}

# Bazaar helper
bzr() {
    case "$1" in
        "commit")
            printf "Is the version up to date? "
            read answer
            if [[ "$answer" != "yes" ]]; then
                echo "Canceled."
                return
            fi;;
        "uncommit")
            echo "This command is disabled."
            return;;
        "diff")
            if [[ -t 1 ]]; then
                command bzr "$@" | colordiff
            else
                command bzr "$@"
            fi
            return;;
    esac
    command bzr "$@"
}

# Git helper
git() {
    case "$1" in
        "commit")
            printf "Is the version up to date? "
            read answer
            if [[ "$answer" != "yes" ]]; then
                echo "Canceled."
                return
            fi;;
        "diff")
            if [[ -t 1 ]]; then
                command git "$@" | colordiff
            else
                command git "$@"
            fi
            return;;
    esac
    command git "$@"
}

# MSYS and MSYS2
if [[ $(uname -o) = Msys ]]; then
    # Aliases
    alias edit="notepad++"
    alias grep="wgrep"
    alias find="wfind"

    # Ignore permission errors
    wgrep() { { command grep "$@" 2>&1 >&3 | command grep -v 'Permission denied'; } 3>&1; }
    wfind() { { command find "$@" 2>&1 >&3 | command grep -v 'Permission denied'; } 3>&1; }

    # SSH authentication
    case $(uname -r) in
        1.*) agent=/usr/bin/ssh-agent ;;
        2.*) agent=/bin/ssh-agent ;;
    esac
    ssh-auth() {
        [[ -z $(ps | grep $agent) ]] && echo $(ssh-agent) > /tmp/ssh-agent-data.sh
        [[ -z $SSH_AGENT_PID ]] && source /tmp/ssh-agent-data.sh > /dev/null
        [[ -z $(ssh-add -l | grep "/home/$(whoami)/.ssh/id_rsa") ]] && ssh-add
    }
    ssh() { ssh-auth; command ssh "$@"; }
    scp() { ssh-auth; command scp "$@"; }
fi

# MSYS
if [[ $(uname -o) = Msys && $(uname -r) = 1.* ]]; then
    # Aliases
    alias whence="type -a"
    alias grep="grep --color=auto"
    alias ls="ls --color=auto --show-control-chars"
    alias msgrep="msgrep --binary-files=text -d skip --color=auto"
    alias msls="msls -bhAC --more --color=auto --recent --streams"
    alias update="mingw-get update && mingw-get upgrade 2> /dev/null"

    # SQLite encoding
    sqlite() {
        arguments=("$@")
        database="${arguments[${#arguments[@]}-2]}"
        sql="${arguments[${#arguments[@]}-1]}"

        [[ -z "${@:2}" ]] && { command sqlite "$@"; return; }
        [[ ! -f "$sql" ]] && encoding=$(command sqlite "$database" "pragma encoding")
        [[ -z "$encoding" ]] && { command sqlite "$@"; return; }

        arguments=()
        for argument in "$@"; do
            argument=$(iconv -f ISO-8859-1 -t "$encoding" <<< "$argument")
            arguments+=("$argument")
        done
        command sqlite "${arguments[@]}" | iconv -f "$encoding" -t ISO-8859-1
    }
fi

# MSYS2
if [[ $(uname -o) = Msys && $(uname -r) = 2.* ]]; then
    alias pacman="pacman --color auto"
fi
