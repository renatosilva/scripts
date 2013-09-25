#!/bin/bash

# Windows Cleanup 2013.9.25
# Copyright (c) 2012, 2013 Renato Silva
# GNU GPLv2 licensed

# Run only on shutdown or --force
shutdown_happening=$(wevtutil qe system //c:1 //rd:true //f:xml //q:"*[System[(EventID=1074) and TimeCreated[timediff(@SystemTime) <= 60000]]]")
[[ -z "$shutdown_happening" && "$1" != "--force" ]] && exit

# Run backup on shutdown, wait for phone sync if not rebooting
non_reboot_shutdown=$(echo "$shutdown_happening" | grep -i "<data>desligado</data>")
[[ -n "$non_reboot_shutdown" ]] && delay="$1"
[[ -n "$shutdown_happening" ]] && mintty -w full bash backup --default "$delay" "Esperando pela sincronização do celular"

# Firefox bookmarks cleanup: remove unorganized and descriptions
database=("$APPDATA/Mozilla/Firefox/profiles/"*"/places.sqlite")
sqlite "$database" "delete from moz_bookmarks where parent = (select folder_id from moz_bookmarks_roots where root_name = 'unfiled')"
sqlite "$database" "delete from moz_items_annos where id in (select i.id from moz_bookmarks b, moz_items_annos i where b.id = i.item_id and b.type = 1
    and title != '' and title not in ('Favoritos do dispositivo móvel', 'Favoritos recentes', 'Mais visitados', 'Tags recentes', 'Histórico', 'Downloads', 'Tags'))"

# Clean up recent files list from Word Viewer
filename="$TEMP/winclean.$(date +%s.%N).reg"
trap "rm -r $filename" EXIT
echo 'Windows Registry Editor Version 5.00
[HKEY_CURRENT_USER\Software\Microsoft\Office\11.0\Wordview\Data]
"Settings"=-' > "$filename"
regedit //s "$filename"

# Clean up WMP junk
reg_data=$(reg query 'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders' //v 'My Music')
music=$(echo "$reg_data" | awk -F'REG_SZ[[:space:]]*' 'NF>1{print $2}')
[[ -d "$music" ]] && find "$music" -iname "*.jpg" -delete

# Clean up bash history
rm -f ~/.bash_history
touch ~/.bash_history
attrib +h ~/.bash_history

# Let CCleaner do its job
reg_data=$(reg query 'HKEY_LOCAL_MACHINE\SOFTWARE\Piriform\CCleaner' //ve)
ccleaner_dir=$(echo "$reg_data" | awk -F'REG_SZ[[:space:]]*' 'NF>1{print $2}')
"$ccleaner_dir/ccleaner.exe" //auto
