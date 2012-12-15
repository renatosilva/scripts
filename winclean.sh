#!/bin/bash

# Windows Cleanup 2012.12.15
# Copyright (c) 2012 Renato Silva
# GNU GPLv2 licensed

# Run only on shutdown
shutdown_happening=$(wevtutil qe system //c:1 //rd:true //f:xml //q:"*[System[(EventID=1074) and TimeCreated[timediff(@SystemTime) <= 60000]]]")
[[ -z "$shutdown_happening" ]] && exit

# Run backup, wait for phone sync if not rebooting
non_reboot_shutdown=$(echo "$shutdown_happening" | grep -i "<data>desligado</data>")
[[ -n "$non_reboot_shutdown" ]] && delay=120
mintty -w full bash backup "$delay"

# Cleanup recent files list from Word Viewer
filename="$TEMP/winclean.$(date +%s.%N).reg"
trap "rm -r $filename" EXIT
echo 'Windows Registry Editor Version 5.00
[HKEY_CURRENT_USER\Software\Microsoft\Office\11.0\Wordview\Data]
"Settings"=-' > "$filename"
regedit //s "$filename"

# Cleanup WMP junk
reg_data=$(reg query 'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders' //v 'My Music')
music=$(echo "$reg_data" | awk -F'REG_SZ[[:space:]]*' 'NF>1{print $2}')
[[ -d "$music" ]] && find "$music" -iname "*.jpg" -delete

# Let CCleaner do its job
reg_data=$(reg query 'HKEY_LOCAL_MACHINE\SOFTWARE\Piriform\CCleaner' //ve)
ccleaner_dir=$(echo "$reg_data" | awk -F'REG_SZ[[:space:]]*' 'NF>1{print $2}')
"$ccleaner_dir/ccleaner.exe" //auto
