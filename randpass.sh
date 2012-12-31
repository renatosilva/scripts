#!/bin/bash

# Random Passowrd 2012.12.31
# Copyright (c) 2012 Renato Silva
# GNU GPLv2 licensed

chars=({{0..9},{a..z},{A..Z}})
total_chars="${#chars[@]}"
length="${1:-12}"
count=1

while [[ "$count" -le "$length" ]]; do
    echo -n "${chars[RANDOM % total_chars]}"
    count=$((count + 1))
done
echo
