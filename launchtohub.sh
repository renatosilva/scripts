#!/bin/bash

##
##     LaunchToHub 2016.1.7
##     Copyright (C) 2015, 2016 Renato Silva
##     Licensed under GPLv2 or later
##
## Usage: @script.name [options] DIRECTORY[.git]...
##
##     -i, --import    Import all branches from Launchpad project DIRECTORY.
##     -h, --help      This help text.
##

header() {
    if [[ -t 1 ]]; then
        local blue="\e[1;34m"
        local green="\e[1;32m"
        local normal="\e[0m"
    fi
    printf "\n${!1}${2}${normal}\n"
}

source easyoptions || exit
test -z "${arguments}" && exit 1
eval $(ssh-agent) || exit
trap "kill ${SSH_AGENT_PID}" EXIT
ssh-add || exit

for repository in "${arguments[@]}"; do
    cd "${repository}" || exit

    # Not project
    if [[ -z "${import}" ]]; then
        header blue "Updating branch ${repository}"; git bzr sync --overwrite || exit
        header green "Pushing branch ${repository}"; git push --force github bzr/master:master || exit
        continue
    fi

    # List branches
    header blue "Updating repository ${repository}"
    project=$(readlink -f .)
    project="${project%.git}"
    project="${project##*/}"
    branches_url="http://feeds.launchpad.net/${project}/branches.atom"
    branches=($(wget -q -O - "${branches_url}" | grep lp: | awk -F'[<>]' '{ print $3 }'))
    test -z "${branches}" && { echo "Failed listing branches for project ${project}"; exit 1; }

    # Import branches
    for branch in "${branches[@]}"; do
        if [[ "${branch}" = "lp:${project}" ]]
            then git_branch='master'
            else git_branch="${branch##*/}"
        fi
        if test -z "$(git branch --list "${git_branch}")"
            then header normal "Importing branch ${branch}"; git bzr import "${branch}" "${git_branch}" || exit
            else header normal "Updating branch ${git_branch}"; git bzr sync --overwrite "bzr/${git_branch}" || exit
        fi
    done

    # Export branches
    header green "Pushing repository ${repository}"
    git_branches=($(git branch | grep -v bzr/ | tr -d '*'))
    for git_branch in "${git_branches[@]}"; do
        header normal "Pushing branch ${git_branch}"
        git push --force github "bzr/${git_branch}:${git_branch}"
    done
    cd - > /dev/null
done
