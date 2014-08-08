#!/bin/bash

unix=(
    "backup"
    "bacon-crypt"
    "check-branches"
    "check-tags"
    "colordiff"
    "csvt"
    "dcim-organizer"
    "dnsdynamic"
    "greprev"
    "numpass"
    "randpass"
    "easyoptions:https://github.com/renatosilva/easyoptions/raw/master/easyoptions.sh"
    "easyoptions.rb:https://github.com/renatosilva/easyoptions/raw/master/easyoptions.rb"
    "vimcat:https://github.com/renatosilva/vimpager/raw/vimcat-msys2/vimcat"
)

windows=(
    "colornote-backup-clean"
    "dosconv"
    "ivona-speak"
    "networkmeter-reset"
    "winclean"
)

msys1=(
    "msys2-msys.bat"
    "packages"
    "runcrt"
    "tz-brazil"
)

winlink() {
    cd "$target"
    [[ -z "$remove" && ! -e "$1" ]] && cmd //c mklink "$1" "$2"
    [[ -n "$remove" &&   -e "$1" ]] && rm -vf "$1"
    cd - > /dev/null
}

download() {
    host="${1#*//}"
    host="${host%%/*}"
    wget -q --no-check-certificate -O "$2/$3" "$1"
    case "$?" in
        0) printf "${host_format:-%s} -> $2/$3\n" "$host" ;;
        *) printf "${warning_format:-%s} failed downloading $3\n" "Warning!" >&2 ;;
    esac
}

# Prepare
target=/usr/local/bin
scripts="${unix[@]}"
mkdir -p "$target"
[[ "$1" = --remove ]] && remove="yes"
[[ -t 1 ]] && host_format="\e[38;05;2m%s\e[0m"
[[ -t 2 ]] && warning_format="\e[38;05;9m%s\e[0m"

# MSYS or MSYS2
if [[ $(uname -o) = Msys ]]; then
    scripts="${scripts[@]} ${windows[@]}"
    for link in attrib cmd ipconfig net ping reg schtasks shutdown taskkill; do winlink "$link" dosconv; done
    winlink speak ivona-speak

    # MSYS
    if [[ $(uname -r) = 1.* ]]; then
        scripts="${scripts[@]} ${msys1[@]}"
        for link in bzr python ruby; do winlink "$link" runcrt; done
    fi
fi

# Deploy
from=$(dirname "$0")
if [[ -z "$remove" ]]; then
    for script in $scripts; do
        case "$script" in
            *http*) download "${script#*:}" "$target" "${script%%:*}" ;;
            *) cp -v "$from/$script"* "$target/$script" ;;
        esac
    done
    cp -v "$from/aliases.sh" /etc/profile.d/aliases.sh
else
    cd "$target"
    for script in $scripts; do rm -vf "${script%%:*}"; done
    rm -vf /etc/profile.d/aliases.sh
    cd - > /dev/null
fi
