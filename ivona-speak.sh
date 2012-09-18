#!/bin/bash

# IVONA Speak 2012.9.18
# Copyright (c) 2012 Renato Silva
# GNU GPLv2 licensed

if [ "$1" = "--chat" ]; then # Speak a chat
    # Someone to someone
    nick="^([^:,> ]{1,16})"
    text="$2: "$(echo "$3" | sed -r s/"$nick:"/"to \\1:"/)
    text=$(echo "$text" | sed -r s/"$nick: to "/"\\1 to "/)

    # Actions
    text=$(echo "$text" | sed -r s/"$nick: \/me "/"\\1 "/)
    text=$(echo "$text" | sed -r s/"$nick '"/"\\1'"/)

    # URLs
    text=$(echo "$text" | sed -r s/"\w{3,5}:\\/\\/\\S+"/"(URL)"/g)

    # Catch remaining arguments
    text="$text ${@:4}"

elif [ ! -z "$2" ]; then # Speak title and text
    text="$1: ${@:2}"

else # Just speak
    text="$1"
fi

# Wait for current speech
try=0
time=$(date +%X)
lock="$TEMP/ivona-speak.lock.txt"
while ! ( set -C; echo "$text" > "$lock") 2> /dev/null; do
    sleep 1
    try=$(($try + 1))
    if [[ "$try" = "60" ]]; then
        log="/c/Users/$USERNAME/Desktop/speak.failed.log"
        echo -e "$time: $text\r" >> "$log"
        exit
    fi
done

# Lock acquired, speak
trap "rm $lock" EXIT
"$(dirname "$0")/IVONA Reader" -o "$lock" -p -q
sleep $(((${#text}/14) + 1))
