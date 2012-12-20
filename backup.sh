#!/bin/bash

# Backup 2012.12.20
# Copyright (c) 2012 Renato Silva
# GNU GPLv2 licensed

target="$1"
delay="$2"
name="Documentos e programas"
[[ -z "$delay" ]] && delay="0"
[[ -z "$target" ]] && target="/dados/backup"
[[ -e "$target" ]] || { echo "Target device not found."; sleep 5; exit 1; }

# Sticky notes and favorites
temp="$TEMP/backup.$(date +%s.%N)"
trap "rm -rf $temp" EXIT
mkdir -p "$temp"
notes="$temp/Anotações"
favorites="$temp/Favoritos"
cp -r "$APPDATA/Microsoft/Sticky Notes" "$notes"
cp -r "$USERPROFILE/Favorites" "$favorites"

# Application settings
tools="/c/programs/ferramentas"
configs="$temp/Configurações"
mkdir -p "$configs"
cp ~/.profile "$configs"
cp "$tools/defraggler/defraggler.ini" "$configs"
cp "$tools/ccleaner/ccleaner.ini" "$configs"
cp "$tools/recuva/recuva.ini" "$configs"
cp "$tools/speccy/speccy.ini" "$configs"
cp "$APPDATA/IVONA 2 Voice/"*".lex" "$configs"

# Registry favorites
key='HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit\Favorites'
data=$(reg query "$key" //s | sed -E s/'^\s+'// | sed s/'\\'/'\\\\\\\\'/g | awk -F'[[:space:]]*REG_SZ[[:space:]]*' 'NF>1{print "\"" $1 "\"=\"" $2 "\""}')
echo -e "Windows Registry Editor Version 5.00\n\n[$key]\n$data\n" | unix2dos > "$configs/regedit.reg"

password=$(cat /dados/documentos/chaves/renatosilva.backup)
7z a "$temp/$name $(date '+%-d.%-m.%Y %-Hh%M').7z" -p"$password" -xr!desktop.ini -mhe "/dados/documentos" "/dados/programas" "$favorites" "$notes" "$configs"
rm "$target/$name "*.7z 2> /dev/null || echo "First backup in this device."
mv "$temp/"*.7z "$target"
sleep $((3 + delay))
