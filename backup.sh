#!/bin/bash

# Backup 2013.4.28
# Copyright (c) 2012, 2013 Renato Silva
# GNU GPLv2 licensed

target="$1"
delay="$2"
name="Documentos e programas"
[[ -z "$delay" ]] && delay="0"
[[ -z "$target" || "$target" = "--default" ]] && target="/dados/backup"
[[ -e "$target" ]] || { echo "Target $target not found."; sleep 5; exit 1; }

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
cp ~/.profile ~/.inputrc ~/.wgetrc ~/.minttyrc "$configs"
cp "$tools/defraggler/defraggler.ini" "$configs"
cp "$tools/ccleaner/ccleaner.ini" "$configs"
cp "$tools/recuva/recuva.ini" "$configs"
cp "$tools/speccy/speccy.ini" "$configs"
cp "$APPDATA/IVONA 2 Voice/"*".lex" "$configs"

# Scheduled tasks
tasks="$configs/Tarefas"
mkdir "$tasks"
for file in "$SYSTEMROOT/System32/Tasks/Usuário/"*; do
    [[ -f "$file" ]] || continue
    taskname=$(basename "$file")
    cp "$file" "$tasks/$taskname.xml"
done

# Shortcuts
startup="$configs/Inicializar"
mkdir "$startup"
cp "$APPDATA/Microsoft/Windows/Start Menu/Programs/Startup/"* "$startup"
cp -r "$APPDATA/Microsoft/Windows/Start Menu/Programs/Ferramentas" "$configs"

# Registry favorites
key='HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit\Favorites'
data=$(reg query "$key" //s | sed -E s/'^\s+'// | sed s/'\\'/'\\\\\\\\'/g | awk -F'[[:space:]]*REG_SZ[[:space:]]*' 'NF>1{print "\"" $1 "\"=\"" $2 "\""}')
echo -e "Windows Registry Editor Version 5.00\n\n[$key]\n$data\n" | unix2dos > "$configs/regedit.reg"

password=$(cat /dados/documentos/privado/chaves/renatosilva.backup)
7z a "$temp/$name $(date '+%-d.%-m.%Y %-Hh%M').7z" -p"$password" -xr!desktop.ini -mhe "/dados/documentos" "/dados/programas" "$favorites" "$notes" "$configs"
rm "$target/$name "*.7z 2> /dev/null || echo "First backup in this device."
mv "$temp/"*.7z "$target"
sleep $((3 + delay))
