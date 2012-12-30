#!/bin/bash

# Numeric Password 2012.12.30
# Copyright (c) 2012 Renato Silva
# GNU GPLv2 licensed

# This program converts alphanumeric passwords into number-only passwords.

i=0
for c in {{a..z},{0..9}}; do
    i=$((i+1))
    nums[$i]="$c"
done
read -p "Password: " -s pwd
pwd=$(echo "$pwd" | sed -E s/"(.)"/" \\1"/g)
for c in $pwd; do
    for ix in {1..36}; do
        [[ "${nums[$ix]}" != "$c" ]] && continue
        [[ "$ix" -gt "26" ]] && ix=$((ix-27))
        echo -n $((ix%10))
        break
    done
done
echo
