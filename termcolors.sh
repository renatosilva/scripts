#!/bin/bash

# Terminal Colors 2012.10.28
# Copyright (c) 2010, 2012 Renato Silva
# GNU GPLv2 licensed

# Based on http://www.commandlinefu.com/commands/view/5879/show-numerical-values-for-each-of-the-256-colors-in-bash.
# See also http://www.pixelbeat.org/docs/terminal_colours/#256.

colors() {
    i=$1
    while [ $i -le $2 ]; do
        if [ "$codes" = "-n" ]; then
            printf "\e[38;05;${i}m%3d " $i
        else
            printf "\e[48;05;${i}m    "
        fi
        printf "\e[0m"
        test $(((i + 1 - $1) % $3)) -eq "0" && echo
        i=$((i + 1))
    done
    echo
}

codes="$1"
colors 0 15 8
colors 16 231 36
colors 232 255 100
