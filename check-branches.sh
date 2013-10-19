#!/bin/bash

# Check branches 2013.10.19
# Copyright (c) 2012, 2013 Renato Silva
# GNU GPLv2 licensed

# This program goes recursively through a directory hierarchy
# and run specified commands on every Bazaar branch that is found.

print_branch_name() {
    printf "%$1s" "--- $(basename "$branch"): " | colordiff 2> /dev/null | sed "s/--- //"
}

run_bzr_command() {
    if [[ "$1" = "missing" ]]; then
        bzr missing --line | grep -v "parent"
        return
    fi
    bzr "$1"
}

check() {
    branch=$(echo "$0" | sed s/".bzr"//)
    if [ "$cmds" != "$def_cmds" ]; then
        first_command="yes"
        print_branch_name ""
        for cmd in $cmds; do
            cd "$branch"
            run_bzr_command "$cmd"
            cd - > /dev/null
            [[ "$first_command" = "no" ]] && continue
            first_command="no"
            echo
        done
        return
    fi
    print_branch_name "-35"
    for cmd in $(echo "$cmds" | sed -r s/" and ([^,])"/" \\1"/ | sed s/","//g); do
        cd "$branch"
        run_bzr_command "$cmd"
        cd - > /dev/null
    done
}

root="$1"
cmds="${@:2}"
def_cmds="missing and status"
[ -z "$1" ] && root="."
[ -z "$cmds" ] && cmds="$def_cmds"

export -f print_branch_name
export -f run_bzr_command
export -f check
export def_cmds
export cmds

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $(basename "$0") [root [commmand]...]"
    echo "Without arguments, root is current directory, and commands are $def_cmds."
    exit
fi

find "$root" -name ".bzr" -type d -exec bash -c check '{}' \;
sleep 3
