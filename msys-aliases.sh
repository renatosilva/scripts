# MinGW MSYS Aliases 2012.10.27
# Copyright (c) 2012 Renato Silva
# GNU GPLv2 licensed

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
    packages=($(mingw-get list | grep ^Package | grep -E "$1" | sed -E s/"Package: (\S*).*"/"\\1"/ | grep -E --color "$1"))
    if [ -z "$2" ]; then
        count="0"
        for package in "${packages[@]}"; do
            count=$((count + 1))
            printf '%#3d %s\n' "$count" "$package"
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

alias update='mingw-get update && mingw-get upgrade 2> /dev/null'

alias grep='grep --color=auto'
alias ls='ls --color=auto --show-control-chars'
alias msgrep='msgrep --binary-files=text -d skip --color=auto'
alias msls='msls -bhAC --more --color=auto --recent --streams'

export LESSHISTFILE="-"
export PS1="\[\e]0;$MSYSTEM \007\e[38;05;117m\]\W\[\e[0m\] \$ "
cd "$USERPROFILE/Desktop"
