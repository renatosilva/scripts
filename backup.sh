#!/bin/bash

##
##     Backup 2015.6.28
##     Copyright (c) 2012-2015 Renato Silva
##     GNU GPLv2 licensed
##
## This is a backup script for Windows. You can configure it with ~/.backuprc.
## Output is a password protected, 7-Zip compressed file which is going to
## replace any previous backup on target directory. Backup will include:
##
##     * Sticky notes
##     * Logoff scripts
##     * Scheduled tasks
##     * Registry favorites
##     * Firefox bookmarks, search plugins and custom website stylesheets
##     * Settings from CCleaner, IVONA, Pidgin, Eclipse and WiFi Guard
##     * Settings from Bash, Git, MinTTY and other tools
##     * Configured program shortcut folders
##     * Configured custom files
##
## Usage:
##     @script.name [options]
##
##     -p, --progress            Show backup progress using graphical interface.
##     -s, --silent              Do not play sound notifications.
##         --wait-lock=MESSAGE   Wait for BACKUP_NAME.lock to be released after
##                               backup is complete, if the system is currently
##                               shutting down.
##     -h, --help                This help text.
##
## Configuration file:
##
##     backup_name        Backup file name, will have date and time appended.
##     files              Array of custom files and directories to save.
##     directory          Custom directory where to store the backup.
##     password           Password for the compressed file.
##
##     eclipse_workspace  Custom Eclipse workspace location.
##     shortcut_folders   Array of program shortcut folders to save.
##     task_folder        Scheduled tasks subfolder to save instead of root.
##     reboot_string      Localized string that identifies reboots in event log.
##     exclude            Array of exclude patterns.
##

# Functions
playsound() { [[ -z "$silent" ]] && powershell -c "(New-Object Media.SoundPlayer 'C:/Windows/Media/${1}.wav').PlaySync()" > /dev/null; }
registry()  { reg query "$1" ${2:+//v} "${2:-//ve}" | awk -F'REG_SZ[[:space:]]*' 'NF>1{print $2}'; }
shelldir()  { powershell -c "[Environment]::GetFolderPath('${1}')"; }
copy()      { test -e "$2" && cp -r "$2" "$1"; }

# Defaults
backup_name="${USERNAME}"
directory="${USERPROFILE}"
shortcut_folders=('Startup')
exclude=('desktop.ini' 'thumbs.db')
eclipse_workspace="${USERPROFILE}/workspace"
files=("$(shelldir MyDocuments)"
       "$(shelldir MyPictures)")

# Initialization
source easyoptions || exit
source ~/.backuprc || exit
temp="${TEMP}/backup.$(date +%s.%N)"
lock="${directory}/${backup_name}.lock"
tempfile="${temp}/${backup_name} $(date '+%-d.%-m.%Y %-Hh%M').7z"
ccleaner_dir=$(registry 'HKLM\SOFTWARE\Piriform\CCleaner')
firefox_profile=("$APPDATA/Mozilla/Firefox/profiles/"*)
configurations="${temp}/${configurations:-Configurations}"
shortcuts="${configurations}/${shortcuts:-Shortcuts}"
tasks="${configurations}/${task:-Tasks}"
notes="${temp}/${notes:-Notes}"

# Exclude flags
exclude_flags=()
for pattern in "${exclude[@]}"; do
    exclude_flags+=("-xr!${pattern}")
done

# Skip wait lock on reboot
current_shutdown=$(wevtutil query-events system //c:1 //rd:true //f:xml //q:"*[System[(EventID=1074) and TimeCreated[timediff(@SystemTime) <= 60000]]]")
rebooting=$(grep -iE "<data[^<>]*>${reboot_string:-restart}</data>" <<<"$current_shutdown")
[[ -n "$rebooting" ]] && unset wait_lock

# Directories
cd "$directory" || exit
trap "rm -rf '$temp'" EXIT
mkdir -p "${configurations}"
mkdir -p "${configurations}/Pidgin"
mkdir -p "${configurations}/Firefox"
mkdir -p "${shortcuts}"
mkdir -p "${tasks}"

# Some applications
copy "${configurations}"       ~/.backuprc
copy "${configurations}"       ~/.bashrc
copy "${configurations}"       ~/.colordiffrc
copy "${configurations}"       ~/.gitconfig
copy "${configurations}"       ~/.inputrc
copy "${configurations}"       ~/.minttyrc
copy "${configurations}"       ~/.profile
copy "${configurations}"       ~/.rubocop.yml
copy "${configurations}"       ~/.vimrc
copy "${configurations}"       ~/.wgetrc
copy "${configurations}"       "${ccleaner_dir}/ccleaner.ini"
copy "${configurations}"       "{eclipse_workspace}"
copy "${configurations}"       "${LOCALAPPDATA}/WiFi Guard"
copy "${configurations}/IVONA" "${APPDATA}/IVONA 2 Voice"
copy "${notes}"                "${APPDATA}/Microsoft/Sticky Notes"

# Pidgin
copy "${configurations}/Pidgin" "${APPDATA}/.purple/pixmaps"
copy "${configurations}/Pidgin" "${APPDATA}/.purple/plugins"
copy "${configurations}/Pidgin" "${APPDATA}/.purple/accounts.xml"
copy "${configurations}/Pidgin" "${APPDATA}/.purple/blist.xml"
copy "${configurations}/Pidgin" "${APPDATA}/.purple/prefs.xml"

# Firefox
copy "${configurations}/Firefox" "${firefox_profile}/bookmarkbackups"
copy "${configurations}/Firefox" "${firefox_profile}/searchplugins"
copy "${configurations}/Firefox" "${firefox_profile}/chrome/userContent.css"

# Scheduled tasks
for file in "${SYSTEMROOT}/System32/Tasks/${task_folder}/"*; do
    test -f "$file" || continue
    taskname=$(basename "$file")
    cp "$file" "${tasks}/${taskname}.xml"
done

# Shortcuts
for folder in "${shortcut_folders[@]}"; do
    copy "${shortcuts}" "${APPDATA}/Microsoft/Windows/Start Menu/Programs/${folder}"
done

# Registry favorites and logoff scripts
reg export 'HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit\Favorites'     "${configurations}/regedit.reg" > /dev/null
reg export 'HKCU\Software\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Logoff\0' "${configurations}/logoff.reg"  > /dev/null

# Compress file
7z${progress:+g} a "$tempfile" -p"$password" "${exclude_flags[@]}" -mhe "$configurations" "$notes" "${files[@]}"
test -f "$tempfile" || exit
rm -f "${directory}/${backup_name} "*.7z
mv "${temp}/"*.7z "$directory"
playsound 'Windows Notify System Generic'

# Wait for lock release
if [[ -n "$wait_lock" ]]; then
    printf "\r${wait_lock}0:00"
    start=$(date +%s)
    touch "$lock"
    while [[ -e "$lock" ]]; do
        elapsed_seconds=$(($(date +%s) - start))
        elapsed_minutes=$((elapsed_seconds / 60))
        elapsed_seconds=$((elapsed_seconds % 60))
        elapsed=$(printf '%s:%02s' ${elapsed_minutes} ${elapsed_seconds})
        wait_message="${wait_lock}${elapsed}"
        printf "\r${wait_message}"
        sleep 0.001
    done
    printf "\r%${#wait_message}s\r" ''
    playsound 'Windows Unlock'
fi
