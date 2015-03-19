#!/bin/bash

##
##     Backup 2015.3.19
##     Copyright (c) 2012-2015 Renato Silva
##     GNU GPLv2 licensed
##
## This is my personal backup script on Windows. You may use it as inspiration
## for writing your own, since it is not really reusable out of the box.
## Output is a password protected, 7-Zip compressed file which is going to
## replace any previous backup on target directory. Backup will include:
##
##     * Sticky notes
##     * Logoff scripts
##     * Scheduled tasks
##     * Registry favorites
##     * Firefox bookmarks, search plugins and custom website stylesheets
##     * Settings from Piriform utilities, IVONA and Pidgin
##     * Startup and some other shortcuts
##
## Usage:
##     @script.name [options]
##
##         --name=FILENAME       Backup file name, will have date and time
##                               appended. Any previous backup with same name
##                               will be deleted, right before saving new one.
##     -p, --progress            Show backup progress using graphical interface.
##     -s, --silent              Do not play sound notifications.
##         --target=DIR          Custom directory where to store the backup.
##         --wait-lock=MESSAGE   Wait for FILENAME.lock to be released after
##                               backup is complete, if the system is currently
##                               shutting down. This is intended for remote
##                               synchronization tools having enough time to
##                               save the resulting file.
##     -h, --help                This help text.
##

play_sound() {
    python -c "import winsound; winsound.PlaySound('C:/Windows/Media/$1.wav', winsound.SND_FILENAME)"
}

piriform_dir() {
    reg query "HKEY_LOCAL_MACHINE\\SOFTWARE\\Piriform\\${1}" //ve | awk -F'REG_SZ[[:space:]]*' 'NF>1{print $2}'
}

source easyoptions || exit
shutdown_happening=$(wevtutil qe system //c:1 //rd:true //f:xml //q:"*[System[(EventID=1074) and TimeCreated[timediff(@SystemTime) <= 60000]]]")
non_reboot_shutdown=$(echo "$shutdown_happening" | grep -iE "<data>(desligado|desligar o sistema)</data>")
[[ -n "$shutdown_happening" && -z "$non_reboot_shutdown" ]] && unset wait_lock

[[ -z "$name" ]] && name="Documentos e programas"
[[ -z "$target" ]] && target="/d/backup"
[[ -e "$target" ]] || { echo "Target $target not found."; sleep 5; exit 1; }

# Sticky notes
temp="$TEMP/backup.$(date +%s.%N)"
trap "rm -rf $temp" EXIT
mkdir -p "$temp"
notes="$temp/Anotações"
cp -r "$APPDATA/Microsoft/Sticky Notes" "$notes"

# Application settings
configs="$temp/Configurações"
mkdir -p "$configs/Pidgin"
for config in bashrc colordiffrc gitconfig inputrc minttyrc profile rubocop.yml vimrc wgetrc; do
    [[ -f ~/.$config ]] && cp ~/.$config "$configs"
done
cp "$(piriform_dir CCleaner)/ccleaner.ini" "$configs"
cp "$(piriform_dir Defraggler)/defraggler.ini" "$configs"
cp "$(piriform_dir Recuva)/recuva.ini" "$configs"
cp "$(piriform_dir Speccy)/speccy.ini" "$configs"
cp "$APPDATA/IVONA 2 Voice/"*".lex" "$configs"
cp "$APPDATA/.purple/accounts.xml" "$configs/Pidgin"
cp "$APPDATA/.purple/blist.xml" "$configs/Pidgin"
cp "$APPDATA/.purple/prefs.xml" "$configs/Pidgin"
cp -r "$APPDATA/.purple/pixmaps" "$configs/Pidgin"
cp -r "$APPDATA/.purple/plugins" "$configs/Pidgin"

# Firefox settings
profile=("$APPDATA/Mozilla/Firefox/profiles/"*)
firefox="$configs/Firefox"
mkdir "$firefox"
cp -r "$profile/bookmarkbackups" "$firefox"
cp -r "$profile/searchplugins" "$firefox"
cp -r "$profile/chrome/userContent.css" "$firefox"

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

# Registry favorites and logoff scripts
reg export 'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit\Favorites' "$configs/regedit.reg" > /dev/null
reg export 'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Logoff\0' "$configs/logoff.reg" > /dev/null

# Generating compressed file
[[ -n "$progress" ]] && suffix="G"
password=$(cat /d/documentos/privado/chaves/renatosilva.backup)
tempfile="$temp/$name $(date '+%-d.%-m.%Y %-Hh%M').7z"
7z$suffix a "$tempfile" -p"$password" -xr!desktop.ini -x!Programas/Branches/Local -mhe "/d/documentos" "/d/programas" "$notes" "$configs"
[[ -f "$tempfile" ]] || exit
rm "$target/$name "*.7z 2> /dev/null || echo "First backup in this device."
mv "$temp/"*.7z "$target"
[[ -z "$silent" ]] && play_sound tada

# Wait for the lock to be released
if [[ -n "$wait_lock" ]]; then
    wait_message="${wait_lock} %s segundos"
    elapsed="0"
    lock="$target/$name.lock"
    touch "$lock"
    while [[ -e "$lock" ]]; do
        sleep 1
        elapsed=$((elapsed + 1))
        printf "\r${wait_message} " "$elapsed"
    done
    printf "\r%${#wait_message}s\r" ""
    [[ -z "$silent" ]] && play_sound notify
else
    sleep 3
fi
