#!/bin/bash

# Numeric Password 2012.11.11
# Copyright (c) 2012 Renato Silva
# GNU GPLv2 licensed

# This program converts alphanumeric passwords into number-only passwords.

i=0
for c in a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9; do
    i=$((i+1))
    nums[$i]="$c"
done
read -p "password: " -s pwd
pwd=$(echo "$pwd" | sed -E s/"(.)"/" \\1"/g)
for c in $pwd; do
    for ix in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36; do
        [[ "${nums[$ix]}" != "$c" ]] && continue
        [[ "$ix" -gt "26" ]] && ix=$((ix-27))
        echo -n $((ix%10))
        break
    done
done
echo
