#!/bin/bash

ntfs_link() {
    [[ ! -e "$1" ]] && cmd //c mklink "$1" "$2";
}

scripts=(
    "backup"
    "bacon-crypt"
    "check-branches"
    "colordiff"
    "colornote-backup-clean"
    "csvt"
    "dcim-organizer"
    "dosconv"
    "dnsdynamic"
    "greprev"
    "networkmeter-reset"
    "numpass"
    "packages"
    "randpass"
    "runcrt"
    "ivona-speak"
    "tz-brazil"
    "winclean"
)

from=$(dirname "$0")
for script in "${scripts[@]}"; do cp -v "$from"/"$script"* "/local/bin/$script"; done
cp -v "$from/msys-aliases.sh" "/etc/profile.d/aliases.sh"
cp -v "$from/parse-options.sh" "/local/bin/parse-options"
cp -v "$from/parse-options.rb" "/local/bin"

cd /local/bin
for link in bzr python ruby; do ntfs_link "$link" runcrt; done
for link in attrib cmd ipconfig net ping reg schtasks shutdown taskkill; do ntfs_link "$link" dosconv; done
ntfs_link speak ivona-speak
cd - > /dev/null
