#!/bin/bash

##
##     Backup 2014.9.29
##     Copyright (c) 2012-2014 Renato Silva
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
##     * Settings from Piriform utilities and IVONA
##     * Startup and some other shortcuts
##
## Usage:
##     @script.name [options]
##
##         --delay=SECONDS       How much time to wait after backup is complete
##                               and, if --wait-on-shutdown is specified, after
##                               the lock file has been released. Will produce a
##                               countdown on command line. Not applied if
##                               system is currently rebooting.
##         --delay-message=TEXT  What message to show for the countdown.
##         --name=FILENAME       Backup file name, will have date and time
##                               appended. Any previous backup with same name
##                               will be deleted, right before saving new one.
##     -p, --progress            Show backup progress using graphical interface.
##     -s, --silent              Whether to play a sound when backup is complete
##                               and after delay time.
##         --target=DIR          Custom directory where to store the backup.
##         --wait-on-shutdown    Wait for a lock file to be released after
##                               backup is complete, if the system is currently
##                               shutting down. This is intended for remote
##                               synchronization tools having enough time to
##                               save the resulting file. The lock file is
##                               created in the target directory as NAME.lock,
##                               where NAME is the backup name.
##     -h, --help                This help text.
##

play_sound() {
    ruby -e "require 'win32/sound'; include Win32; Sound.play('C:\\Windows\\Media\\$1.wav')"
}

source easyoptions || exit
shutdown_happening=$(wevtutil qe system //c:1 //rd:true //f:xml //q:"*[System[(EventID=1074) and TimeCreated[timediff(@SystemTime) <= 60000]]]")
non_reboot_shutdown=$(echo "$shutdown_happening" | grep -iE "<data>(desligado|desligar o sistema)</data>")
[[ -n "$shutdown_happening" && -z "$non_reboot_shutdown" ]] && rebooting="yes"

[[ -z "$delay" || -n "$rebooting" ]] && delay="0"
[[ -z "$delay_message" ]] && delay_message="Esperando..."
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
tools="/c/programs/ferramentas"
configs="$temp/Configurações"
mkdir -p "$configs"
for config in bashrc inputrc minttyrc profile vimrc colordiffrc wgetrc; do
    [[ -f ~/.$config ]] && cp ~/.$config "$configs"
done
cp "$tools/defraggler/defraggler.ini" "$configs"
cp "$tools/ccleaner/ccleaner.ini" "$configs"
cp "$tools/recuva/recuva.ini" "$configs"
cp "$tools/speccy/speccy.ini" "$configs"
cp "$APPDATA/IVONA 2 Voice/"*".lex" "$configs"

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
[[ -z "$wait_on_shutdown" && "$delay" < 1 ]] && { sleep 3; exit 0; }

# Wait for the lock to be released
delay_message="$delay_message %${#delay}s segundos"
if [[ -n "$non_reboot_shutdown" && -n "$wait_on_shutdown" ]]; then
    elapsed="0"
    lock="$target/$name.lock"
    touch "$lock"
    while [[ -e "$lock" ]]; do
        sleep 1
        elapsed=$((elapsed + 1))
        printf "\r$delay_message " "$elapsed"
    done
fi

# Wait for specified delay time
remaining="$delay"
while [[ "$remaining" > 0 ]]; do
    printf "\r$delay_message " "$remaining"
    remaining=$((remaining - 1))
    sleep 1
done
printf "\r%${#delay_message}s\r" ""
[[ -z "$silent" && "$delay" != "0" ]] && play_sound notify
