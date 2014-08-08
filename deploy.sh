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
    [[ ! -e "$1" ]] && cmd //c mklink "$1" "$2"
    cd - > /dev/null
}

# Prepare
target=/usr/local/bin
scripts="${unix[@]}"
mkdir -p "$target"

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
for script in $scripts; do cp -v "$from/$script"* "$target/$script"; done
cp -v "$from/aliases.sh" /etc/profile.d/aliases.sh
