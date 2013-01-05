#!/bin/bash

scripts=(
    "backup"
    "check-branches"
    "check-brst-commits"
    "csvt"
    "greprev"
    "numpass"
    "randpass"
    "speak"
    "tz-brazil"
    "winclean"
)

from=$(dirname "$0")
for script in "${scripts[@]}"; do
    cp -v "$from"/*"$script"* "/local/$script"
done

cp -v "$from/runcrt.sh" "/local/runcrt"
cp -v "$from/dosconv.sh" "/local/dosconv"
cp -v "$from/msys-aliases.sh" "/etc/profile.d/aliases.sh"
