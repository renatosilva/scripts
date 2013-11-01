#!/bin/bash

##
##     Check Branches 2013.11.1
##     Copyright (c) 2012, 2013 Renato Silva
##     GNU GPLv2 licensed
##
## This program goes recursively through a directory hierarchy and checks all
## of the contained Bazaar branches for synchronization status and pending work.
## In other words, the Bazaar commands missing and status. Usage and options:
##
##     @script.name [options] [root directory if not current]
##
##         --no-color         Disable colors in output.
##     -s, --status-only      Do not perform the missing command, only status.
##     -u, --purge-uncommits  Actually remove from the branch any commit that
##                            has been reverted with the uncommit command. This
##                            is done by recreating the branch. Branches with
##                            pending work are skipped.
##     -h, --help             This help text.
##

print_name() {
    local branch_name="$(basename "$(readlink -m "$1")")"
    printf "${green_color}%$2s${normal_color} " "$branch_name:"
}

check() {
    branch="$(dirname "$0")"
    status=$(bzr status "$branch")
    if [[ -n "$purge_uncommits" ]]; then
        if [[ -z "$status" ]]; then
            branch_old="$branch.$(date +%s.%N).temp"
            mv "$branch" "$branch_old"
            branch_output=$(bzr branch "$branch_old" "$branch" 2>&1)
            config=".bzr/branch/branch.conf"
            if [[ -f "$branch_old/$config" ]]; then
                cp "$branch_old/$config" "$branch/$config"
            else
                rm -f "$branch/$config"
            fi
            rm -rf "$branch_old"
        else
            branch_output="Uncommitted changes, ignoring."
        fi
    fi
    if [ -n "$status_only" ]; then
        [[ -n "$purge_uncommits" ]] && padding="-35"
        print_name "$branch" "$padding"
        echo "$branch_output"
        [[ -n "$status" ]] && echo "$status"
        return
    fi
    print_name "$branch" "-35"
    [[ -n "$purge_uncommits" ]] && printf "%-35s " "$branch_output"
    cd "$branch"
    bzr missing --line | grep -v "parent"
    [[ -n "$status" ]] && echo "$status"
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

find "${arguments[0]:-.}" -name ".bzr" -type d -print | xargs -l bash -c check | iconv -f cp850 -t iso-8859-1
sleep 3
