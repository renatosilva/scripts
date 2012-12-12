#!/bin/bash

# Windows Cleanup 2012.12.12
# Copyright (c) 2012 Renato Silva
# GNU GPLv2 licensed

# If not rebooting, backup and wait for phone sync
shutdown=$(wevtutil qe system //c:1 //f:xml //q:"*[System[(EventID=1074) and TimeCreated[timediff(@SystemTime) <= 60000]]]")
non_reboot_shutdown=$(echo "$shutdown" | grep -i "<data>desligado</data>")
[[ -n "$non_reboot_shutdown" ]] && backup.sh 120

# Cleanup recent files list from Word Viewer
filename="$TEMP/winclean.$(date +%s.%N).reg"
trap "rm -r $filename" EXIT
echo "Windows Registry Editor Version 5.00
[HKEY_CURRENT_USER\Software\Microsoft\Office\11.0\Wordview\Data]
"Settings"=-" > "$filename"
regedit //s "$filename"

# Cleanup WMP junk
find "/dados/música" -iname "*.jpg" -delete

# Let CCleaner do its job
/windows/programs/ferramentas/ccleaner/ccleaner.exe //auto
