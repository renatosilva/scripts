#!/bin/bash

# Backup 2012.12.12
# Copyright (c) 2012 Renato Silva
# GNU GPLv2 licensed

delay="$1"
target="$2"
name="Documentos e programas"
[[ -z "$delay" ]] && delay="0"
[[ -z "$target" ]] && target="/dados/backup"
[[ -e "$target" ]] || { echo "Target device not found."; sleep 5; exit 1; }

temp="$TEMP/backup.$(date +%s.%N)"
trap "rm -r $temp" EXIT
mkdir -p "$temp"
notes="$temp/Anotações"
favorites="$temp/Favoritos"
cp -r "$APPDATA/Microsoft/Sticky Notes" "$notes"
cp -r "$USERPROFILE/Favorites" "$favorites"

password=$(cat /dados/documentos/chaves/renatosilva.backup)
7z a "$temp/$name $(date '+%-d.%-m.%Y %-Hh%M').7z" -p"$password" -xr!desktop.ini -mhe "/dados/documentos" "/dados/programas" "$favorites" "$notes"
rm "$target/$name "*.7z 2> /dev/null || echo "First backup in this device."
mv "$temp/"*.7z "$target"
sleep $((3 + delay))
