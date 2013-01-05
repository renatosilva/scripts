#!/bin/bash

scripts=(
    "backup"
    "check-branches"
    "check-brst-commits"
    "csvt"
    "dosconv"
    "greprev"
    "numpass"
    "randpass"
    "runcrt"
    "speak"
    "tz-brazil"
    "winclean"
)

from=$(dirname "$0")
for script in "${scripts[@]}"; do cp -v "$from"/*"$script"* "/local/$script"; done
cp -v "$from/msys-aliases.sh" "/etc/profile.d/aliases.sh"
