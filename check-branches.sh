#!/bin/bash

# Check branches 2012.10.27
# Copyright (c) 2012 Renato Silva
# GNU GPLv2 licensed

# This program goes recursively through a directory hierarchy
# and run specified commands on every Bazaar branch that is found.

check() {
    branch=$(echo "$0" | sed s/".bzr"//)
    if [ "$cmds" != "$def_cmds" ]; then        
        echo "branch: $branch"        
        for cmd in $cmds; do
            cd "$branch"
            bzr $cmd
            cd - > /dev/null
        done        
        return
    fi
    for cmd in $(echo "$cmds" | sed -E s/", and ([^,])"/" \\1"/ | sed s/","//g); do
        cd "$branch"
        bzr $cmd | grep -v "parent"
        cd - > /dev/null
    done
}

root="$1"
cmds="${@:2}"
def_cmds="diff, status, and missing"
[ -z "$1" ] && root="."
[ -z "$cmds" ] && cmds="$def_cmds"
export -f check
export cmds

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 [root [commmand]...]"
    echo "Without arguments, root is current directory, and commands are $def_cmds."
    exit
fi

find "$root" -name ".bzr" -type d -exec bash -c check '{}' \;
echo "Terminado."
sleep 3
