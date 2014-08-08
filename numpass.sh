#!/bin/bash

# Numeric Password 2014.8.8
# Copyright (c) 2012 Renato Silva
# GNU GPLv2 licensed

# This program converts alphanumeric passwords into number-only passwords.

nums=({{a..z},{0..9},{A..Z}})
read -p "Password: " -s pwd
pwd=$(echo "$pwd" | sed -E s/"(.)"/" \\1"/g)
for c in $pwd; do
    for ix in {0..61}; do
        [[ "${nums[$ix]}" != "$c" ]] && continue
        [[ "$ix" -gt "25" && "$ix" -lt "36" ]] && ix=$((ix-27))
        echo -n $(((ix+1)%10))
        break
    done
done
echo
