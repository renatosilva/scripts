#!/bin/bash

##
##     Check Branch Tags 2014.8.8
##     Copyright (c) 2014 Renato Silva
##     GNU GPLv2 licensed
##
## This program goes recursively through a directory hierarchy and checks all
## of the contained Bazaar branches for tag synchronization with parent branch.
## Usage and options:
##
##     @script.name [options] [root directory if not current]
##
##         --no-color         Disable colors in output.
##     -h, --help             This help text.
##

print_name() {
    local branch_name="$(basename "$(readlink -m "$1")")"
    printf "${green_color}%$2s${normal_color} " "$branch_name:"
}

# Convert SSH locations to HTTPS
branch_location() {
    location="$1"
    if [[ "$location" = bzr+ssh:* ]]; then
        location="${location/bzr+ssh/https}"
        location="${location/\/+branch/}"
        location="${location/bazaar./}"
    fi
    echo "$location"
}

check() {
    branch="$(dirname "$0")"
    config=".bzr/branch/branch.conf"
    print_name "$branch" "-35"
    cd "$branch"

    [[ -f "$config" ]] && parent=$(grep ^parent_location "$config" | awk -F' *= *' '{ print $2 }')
    if [[ -z "$parent" ]]; then
        echo "No parent."
        return
    fi

    echo >> "$local_tags"
    echo >> "$parent_tags"

    print_name "$branch" >> "$local_tags"
    print_name "$branch" >> "$parent_tags"

    echo >> "$local_tags"
    echo >> "$parent_tags"

    bzr tags >> "$local_tags"
    bzr tags --directory $(branch_location "$parent") >> "$parent_tags"
    cd - > /dev/null
    echo "Done."
}

eval "$(from="$0" easyoptions.rb "$@" || echo exit 1)"
export -f branch_location
export -f print_name
export -f check

# Colorize text if standard output is a terminal and colors have not been disabled
if [[ -t 1 && -z "$no_color" ]]; then
    export normal_color="\e[0m"
    export green_color="\e[0;32m"
    export diff_command="colordiff"
fi

temp_dir="/tmp/check-tags.$(date +%s.%N)"
export local_tags="$temp_dir/tags.local.txt"
export parent_tags="$temp_dir/tags.parent.txt"

mkdir "$temp_dir"
touch "$local_tags"
touch "$parent_tags"
trap "rm -rf $temp_dir" EXIT

find "${arguments[0]:-.}" -name ".bzr" -type d -print0 | xargs -0 -l -r bash -c check | iconv -f cp850 -t iso-8859-1
echo; ${diff_command:-diff} -U1000000000 "${local_tags}" "$parent_tags" | sed -E "s/(\e.*)?---.*/--- Local tags/" | sed -E "s/(\e.*)?\+\+\+.*/+++ Parent tags/" | grep -v "@@.*@@"
exit 0
