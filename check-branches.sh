#!/bin/bash

##
##     Check Branches 2013.10.23
##     Copyright (c) 2012, 2013 Renato Silva
##     GNU GPLv2 licensed
##
## This program goes recursively through a directory hierarchy and checks all
## of the contained Bazaar branches for synchronization status and pending work.
## In other words, the Bazaar commands missing and status. Usage and options:
##
##     @script.name [options] [root directory if not current]
##
##     --no-color         Disable colors in output.
##     --status-only, -s  Will not perform the missing command, only status one.
##

print_name() {
    local branch_name="$(basename "$(readlink -m "$1")")"
    printf "${green_color}%$2s${normal_color} " "$branch_name:"
}

check() {
    branch="$(dirname "$0")"
    cd "$branch"
    if [ -n "$status_only" ]; then
        print_name "$branch"
        echo "$(bzr status)"
        cd - > /dev/null
        return
    fi
    print_name "$branch" "-35"
    bzr missing --line | grep -v "parent"
    bzr status
    cd - > /dev/null
}

source parse-options || exit 1
export -f print_name
export -f check

# Colorize text if standard output is a terminal and colors have not been disabled
if [[ -t 1 && -z "$no_color" ]]; then
    export normal_color="\e[0m"
    export green_color="\e[0;32m"
fi

find "${arguments[0]:-.}" -name ".bzr" -type d -exec bash -c check '{}' \;
sleep 3
