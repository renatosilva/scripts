#!/bin/bash

# Windows Cleanup 2012.12.12
# Copyright (c) 2012 Renato Silva
# GNU GPLv2 licensed

# Backup on shutdown
shutdown_happening=$(wevtutil qe system //c:1 //rd:true //f:xml //q:"*[System[(EventID=1074) and TimeCreated[timediff(@SystemTime) <= 60000]]]")
if [[ -n "$shutdown_happening" ]]; then
    non_reboot_shutdown=$(echo "$shutdown_happening" | grep -i "<data>desligado</data>")
    # Wait for phone sync if not rebooting
    [[ -n "$non_reboot_shutdown" ]] && delay=120
    mintty -w full bash backup "$delay"
fi;

# Cleanup recent files list from Word Viewer
filename="$TEMP/winclean.$(date +%s.%N).reg"
trap "rm -r $filename" EXIT
echo 'Windows Registry Editor Version 5.00
[HKEY_CURRENT_USER\Software\Microsoft\Office\11.0\Wordview\Data]
"Settings"=-' > "$filename"
regedit //s "$filename"

# Cleanup WMP junk
find "/dados/música" -iname "*.jpg" -delete

# Let CCleaner do its job
/windows/programs/ferramentas/ccleaner/ccleaner.exe //auto
