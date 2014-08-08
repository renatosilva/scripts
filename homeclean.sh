#!/bin/bash

# Home Directories Cleaner 2014.8.8
# Copyright (c) 2012, 2013 Renato Silva
# GNU GPLv2 licensed

files=(
    ".*.log"
    ".xsession-errors*"
    ".local/share/Trash/*"
    ".purple/logs"
    ".thumbnails"
)

for home in /home/* /root; do
    for file in "${files[@]}"; do
        rm -rfv "$home"/$file
    done

    if [[ -d "$home" ]]; then
        cd "$home"
        [[ -f ".cleanrc" ]] && source ".cleanrc"
    fi
done
