#!/bin/bash

if [[ -z "$1" ]]; then
    echo "LaunchToHub 2015.4.24"
    echo "Copyright (C) 2015 Renato Silva"
    echo "Licensed under GPLv2 or later"
    echo "Usage: $(basename "$0") REPOSITORY..."
    exit
fi

eval $(ssh-agent) || exit
trap "kill ${SSH_AGENT_PID}" EXIT
ssh-add || exit

if [[ -t 1 ]]; then
    blue="\e[1;34m"
    green="\e[1;32m"
    normal="\e[0m"
fi

for repository in "$@"; do
    cd "${repository}" || exit

    printf "\n${blue}Updating ${repository}${normal}\n"
    git bzr sync --overwrite || exit

    printf "\n${green}Pushing ${repository}${normal}\n"
    git push --force github bzr/master:master
    cd - > /dev/null
done
