# MinGW MSYS Aliases 2014.8.8
# Copyright (c) 2012-2014 Renato Silva
# GNU GPLv2 licensed

find() {
    { command find "$@" 2>&1 >&3 | command grep -v 'Permission denied'; } 3>&1
}

grep() {
    { command grep "$@" 2>&1 >&3 | command grep -v 'Permission denied'; } 3>&1
}

diff() {
    local prefix
    if [[ -t 1 ]]; then
        prefix="color"
    fi
    command "${prefix}diff" "$@"
}

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

ssh-auth() {
    [[ -z $(ps | grep ssh-agent) ]] && echo $(ssh-agent) > /tmp/ssh-agent-data.sh
    [[ -z $SSH_AGENT_PID ]] && source /tmp/ssh-agent-data.sh > /dev/null
    [[ -z $(ssh-add -l | grep "/home/$(whoami)/.ssh/id_rsa") ]] && ssh-add
}

ssh() { ssh-auth; command ssh "$@"; }
scp() { ssh-auth; command scp "$@"; }

sqlite() {
    if [[ -z "${@:2}" ]]; then
        command sqlite "$@"
        return
    fi

    args=("$@")
    db="${args[${#args[@]}-2]}"
    sql="${args[${#args[@]}-1]}"
    [[ ! -f "$sql" ]] && encoding=$(command sqlite "$db" "pragma encoding")

    if [[ -z "$encoding" ]]; then
        command sqlite "$@"
        return
    fi

    args=()
    for arg in "$@"; do
        arg=$(iconv -f ISO-8859-1 -t "$encoding" <<< "$arg")
        args+=("$arg")
    done
    command sqlite "${args[@]}" | iconv -f "$encoding" -t ISO-8859-1
}

alias update="mingw-get update && mingw-get upgrade 2> /dev/null"
alias hl="grep -C 1000000"
alias hli="hl -i"
alias edit="notepad++"
alias grepi="grep -i"
alias cat="vimcat"

alias type="type -a"
alias grep="grep --color=auto"
alias ls="ls --color=auto --show-control-chars"

alias msgrep="msgrep --binary-files=text -d skip --color=auto"
alias msls="msls -bhAC --more --color=auto --recent --streams"
