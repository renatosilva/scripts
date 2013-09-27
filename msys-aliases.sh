# MinGW MSYS Aliases 2013.9.26
# Copyright (c) 2012, 2013 Renato Silva
# GNU GPLv2 licensed

find() {
    { command find "$@" 2>&1 >&3 | command grep -v 'Permission denied'; } 3>&1
}

grep() {
    { command grep "$@" 2>&1 >&3 | command grep -v 'Permission denied'; } 3>&1
}

bzr() {
    case "$1" in
        "commit")
            printf "Is the version up to date? "
            read answer
            if [ "$answer" != "yes" ]; then
                echo "Canceled."
                return
            fi;;
        "uncommit")
            echo "This command is disabled."
            return;;
        "diff")
            command bzr "$@" | colordiff
            return;;
    esac
    command bzr "$@"
}

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

packages() {
    # List packages
    if [ -z "$1" ]; then
        mingw-get list
        return
    fi

    # Extra argument
    if [ -n "$3" ]; then
        echo "Extra argument: $3"
        return
    fi

    # Full search
    if [ "$2" = "--full" ]; then
        mingw-get list | grep --color -C4 "$1"
        return
    fi

    # Invalid index
    if [[ -n "$2" && ! "$2" =~ "^[0-9]+$" ]]; then
        echo "Invalid index: $2"
        return
    fi

    # Name search
    packages=($(mingw-get list | grep ^Package | grep -i "$1" | sed -E s/"Package: (\S*).*"/"\\1"/))
    if [ -z "$2" ]; then
        count="0"
        for package in "${packages[@]}"; do
            count=$((count + 1))
            printf '%#3d %s\n' "$count" "$package" | grep -i --color "$1"
        done
        return
    fi

    # Index search
    count="0"
    for package in "${packages[@]}"; do
        count=$((count + 1))
        if [ "$count" == "$2" ]; then
            mingw-get show "${packages[$(($2-1))]}"
            return
        fi
    done
    echo "No package found at search index $2"
}

alias update="mingw-get update && mingw-get upgrade 2> /dev/null"
alias edit="notepad++"

alias type="type -a"
alias diff="colordiff"
alias grep="grep --color=auto"
alias ls="ls --color=auto --show-control-chars"

alias msgrep="msgrep --binary-files=text -d skip --color=auto"
alias msls="msls -bhAC --more --color=auto --recent --streams"
