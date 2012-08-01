#!/bin/bash

cmds="$@"
[ -z "$cmds" ] && cmds="diff status missing"

for cmd in $cmds; do
    for branch in *; do
        [ -d "$branch" ] || continue
        cd "$branch"
        bzr $cmd | grep -v "parent"
        cd ..
    done
done

echo "Terminado."
sleep 3
