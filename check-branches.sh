#!/bin/bash

##
##     Check Branches 2014.9.12
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
##         --timestamp=REGEX  Check if commit timestamps match REGEX.
##         --date=REGEX       Restrict --timestamp to dates matching REGEX.
##
##     -s, --status-only      Do not perform the missing command, only status.
##         --purge-uncommits  Actually remove from the branch any commit that
##                            has been reverted with the uncommit command. This
##                            is done by recreating the branch. Branches with
##                            pending work or without dead heads are skipped.
##     -h, --help             This help text.
##

saved_size() {
    size1=$(du -sb "$1" | cut -f1)
    size2=$(du -sb "$2" | cut -f1)
    local size_diff_bytes=$((size1 - size2))
    local size_diff
    [[ "$size_diff_bytes" = 0 ]] && return
    if [[ "$size_diff_bytes" -ge 0 ]]; then
        saved_or_spent="Saved"
    else
        saved_or_spent="${red_color}Spent"
        color="$red_color"
    fi
    if [[ "$size_diff_bytes" -gt -$((1024**2)) && "$size_diff_bytes" -lt $((1024**2)) ]]; then
        size_diff=$(awk -v diff="$size_diff_bytes" 'BEGIN { printf "%.1f", diff / 1024 }')
        size_diff="${size_diff} KB"
    else
        size_diff=$(awk -v diff="$size_diff_bytes" 'BEGIN { printf "%.1f", diff / 1024 / 1024 }')
        size_diff="${size_diff} MB"
        color="${color:-$blue_color}"
    fi
    printf "${color}%$3s${normal_color}" "$saved_or_spent ${size_diff#-}"
}

print_name() {
    local branch_name="$(basename "$(readlink -m "$1")")"
    printf "${green_color}%$2s${normal_color} " "$branch_name:"
}

check() {
    branch="$(dirname "$0")"
    status=$(bzr status "$branch")
    config=".bzr/branch/branch.conf"
    [[ -n "$timestamp" ]] && timestamp=$(bzr log "$branch" | grep ^timestamp: | grep -E "$date" | grep -vE " $timestamp")
    if [[ -n "$purge_uncommits" ]]; then
        dead_heads=$(bzr heads --dead-only "$branch")
        if [[ -n "$dead_heads" && -z "$status" ]]; then
            branch_old="$branch.$(date +%s.%N).temp"
            mv "$branch" "$branch_old"
            branch_output=$(bzr branch "$branch_old" "$branch" 2>&1)
            if [[ -f "$branch_old/$config" ]]; then
                cp "$branch_old/$config" "$branch/$config"
            else
                rm -f "$branch/$config"
            fi
            saved=$(saved_size "$branch_old" "$branch" "-20")
            branch_output=$(printf "%-30s${saved}" "$branch_output")
            rm -rf "$branch_old"
        elif [[ -z "$dead_heads" ]]; then
            branch_output=$(printf "%-50s" "No uncommits to purge.")
        else
            branch_output=$(printf "%-50s" "Pending status, ignoring.")
        fi
    fi
    if [ -n "$status_only" ]; then
        [[ -n "$purge_uncommits" ]] && padding="-35"
        print_name "$branch" "$padding"
        echo "$branch_output"
        [[ -n "$status" ]] && echo "$status"
        [[ -n "$timestamp" ]] && echo "$timestamp"
        return
    fi
    print_name "$branch" "-35"
    [[ -n "$purge_uncommits" ]] && printf "$branch_output "
    cd "$branch"
    [[ -f "$config" ]] && parent=$(grep ^parent_location "$config")
    [[ -n "$parent" ]] && bzr missing --line | grep -v "parent" || echo
    [[ -n "$status" ]] && echo "$status"
    [[ -n "$timestamp" ]] && echo "$timestamp"
    cd - > /dev/null
}

source easyoptions || exit
export timestamp date status_only purge_uncommits
export -f saved_size
export -f print_name
export -f check

# Colorize text if standard output is a terminal and colors have not been disabled
if [[ -t 1 && -z "$no_color" ]]; then
    export normal_color="\e[0m"
    export green_color="\e[0;32m"
    export blue_color="\e[38;05;27m"
    export red_color="\e[38;05;9m"
fi

find "${arguments[0]:-.}" -name ".bzr" -type d -print0 | xargs -0 -l -r bash -c check | iconv -f cp850 -t iso-8859-1
sleep 3
