#!/bin/bash

# DCIM Organizer 2014.8.8
# Copyright (c) 2013 Renato Silva
# GNU GPLv2 licensed

[[ -z "$1" ]] && echo "Usage: $(basename "$0") <directory> [number to start from]" && exit
shopt -s nullglob

rename() {
    find "$1" -type d -print0 | while IFS= read -r -d '' dir; do
        count="$4"
        [[ -z "$count" ]] && count="1"
        for file in "$dir/$2"*".$3"; do
            prefix="$(basename "$dir")"
            [[ "$prefix" == "Câmera" ]] && break
            mv -v "$file" "$(dirname "$file")/$count.$3"
            count=$((count + 1))
        done
    done
}

rename "$1" "DSC_" "jpg" "$2"
rename "$1" "MOV_" "mp4" "$2"
