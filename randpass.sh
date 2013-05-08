#!/bin/bash

# Random Password 2013.5.7
# Copyright (c) 2012, 2013 Renato Silva
# GNU GPLv2 licensed

chars=({{0..9},{a..z},{A..Z}})
total_chars="${#chars[@]}"
length="${1:-12}"
count=1

while [[ "$count" -le "$length" ]]; do
    max_random=$(((32768 / total_chars) * total_chars))
    random=$((max_random + 1))
    while [[ "$random" -gt "$max_random" ]]; do
        random="$RANDOM"
    done
    echo -n "${chars[random % total_chars]}"
    count=$((count + 1))
done
echo
