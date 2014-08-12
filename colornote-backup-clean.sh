#!/bin/bash

# ColorNote Backup Cleanup 2014.8.12
# Copyright (c) 2012, 2013 Renato Silva
# GNU GPLv2 licensed

for extension in dat idx; do
    files=(/d/backup/notas/*".$extension")
    [[ "${#files[@]}" == 0 ]] && continue
    for i in {1..7}; do
        unset files["${#files[@]}-1"]
    done
    rm -vf "${files[@]}"
done
