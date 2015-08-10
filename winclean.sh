#!/bin/bash

# Windows Cleanup 2015.8.10
# Copyright (c) 2012-2015 Renato Silva
# GNU GPLv2 licensed

# Kill the running SSH agents
taskkill //f //im ssh-agent.exe > /dev/null 2>&1

# Clean up bash history
if [[ $(uname -or) = 1.*Msys ]]; then
    rm -f ~/.bash_history
    touch ~/.bash_history
    attrib +h ~/.bash_history > /dev/null
else
    echo -n > ~/.bash_history
fi

# Firefox bookmarks cleanup: remove unorganized and descriptions
database=("$APPDATA/Mozilla/Firefox/profiles/"*"/places.sqlite")
sqlite3 "$database" "delete from moz_bookmarks where parent = (select folder_id from moz_bookmarks_roots where root_name = 'unfiled')"
sqlite3 "$database" "delete from moz_items_annos where id in (select i.id from moz_bookmarks b, moz_items_annos i where b.id = i.item_id and b.type = 1
    and title != '' and title not in ('Favoritos do dispositivo m�vel', 'Favoritos recentes', 'Mais visitados', 'Tags recentes', 'Hist�rico', 'Downloads', 'Tags'))"

# Clean up recent files and search history from Notepad++
npp_config="$APPDATA/Notepad++/config.xml"
sed -i -E "/^\\s+<File\\s+filename=.*$/d" "$npp_config"
sed -i -E "/^\\s+<(Find|Replace)\\s+name=.*$/d" "$npp_config"
unix2dos --quiet "$npp_config" 2> /dev/null

# Clean up recent files list from Word Viewer
reg delete 'HKEY_CURRENT_USER\Software\Microsoft\Office\11.0\Wordview\Data' //v Settings //f > /dev/null

# Clean up WMP junk
reg_data=$(reg query 'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders' //v 'My Music')
music=$(echo "$reg_data" | awk -F'REG_SZ[[:space:]]*' 'NF>1{print $2}')
[[ -d "$music" ]] && find "$music" -iname "*.jpg" -delete

# Let CCleaner do its job
reg_data=$(reg query 'HKEY_LOCAL_MACHINE\SOFTWARE\Piriform\CCleaner' //ve)
ccleaner_dir=$(echo "$reg_data" | awk -F'REG_SZ[[:space:]]*' 'NF>1{print $2}')
test -z "$ccleaner_dir" && ccleaner_dir='/c/Program Files/CCleaner'
"$ccleaner_dir/ccleaner.exe" //auto
[[ "$1" != --wait ]] && exit
while [[ -n $(tasklist | grep -i ccleaner) ]]; do
    sleep 1
done
