#!/bin/bash

local=(
    "backup"
    "check-branches"
    "check-brst-commits"
    "csvt"
    "greprev"
    "speak"
    "numpass"
    "tz-brazil"
    "winclean"
)

from=$(dirname "$0")
for script in "${local[@]}"; do
    cp -v "$from"/*"$script"* "/local/$script"
done

cp -v "$from/runcrt.sh" "/local/runcrt"
cp -v "$from/dosconv.sh" "/local/dosconv"
cp -v "$from/msys-aliases.sh" "/etc/profile.d/aliases.sh"
