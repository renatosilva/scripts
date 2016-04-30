#!/bin/bash

# Windows Cleanup 2016.4.30
# Copyright (c) 2012-2016 Renato Silva
# GNU GPLv2 licensed

exec >/dev/null 2>&1
notepad_plus="${APPDATA}/Notepad++/config.xml"
bookmarks=("${APPDATA}/Mozilla/Firefox/profiles/"*/places.sqlite)
ccleaner="$(cat /proc/registry/HKEY_LOCAL_MACHINE/SOFTWARE/Piriform/CCleaner/@)"
music="$(cat '/proc/registry/HKEY_CURRENT_USER/Software/Microsoft/Windows/CurrentVersion/Explorer/Shell Folders/My Music')"
firefox() { test -f "${bookmarks}" && sqlite3 "${bookmarks}" "${1}"; }

# SSH, bash history and WMP
taskkill -f -im ssh-agent.exe
truncate --size=0 ~/.bash_history
test -d "${music}" && find "${music}" -iname '*.jpg' -delete

# Unorganized bookmarks and descriptions
firefox "delete from moz_bookmarks where parent = (select folder_id from moz_bookmarks_roots where root_name = 'unfiled')"
firefox "delete from moz_items_annos where id in (select i.id from moz_bookmarks b, moz_items_annos i where b.id = i.item_id
         and b.type = 1 and title != '' and title not in ('Favoritos do dispositivo móvel', 'Favoritos recentes',
         'Mais visitados', 'Tags recentes', 'Histórico', 'Downloads', 'Tags'))"

# Notepad++ recent files and searches
sed -i -r '/^\s+<(Find|Replace)\s+name=.*$/d' "${notepad_plus}"
sed -i -r '/^\s+<File\s+filename=.*$/d' "${notepad_plus}"
unix2dos "${notepad_plus}"

# Execute CCleaner
PATH="${PATH}:$(cygpath --unix "${ccleaner}")" ccleaner //auto
[[ "${1}" = --wait ]] && while test -n "$(tasklist | grep -i ccleaner)"; do sleep 1; done
