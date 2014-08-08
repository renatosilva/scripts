#!/bin/bash

# PPK Add 2014.8.8
# Copyright (c) 2010, 2012, 2013 Renato Silva
# GNU GPLv2 licensed

# This program adds a PuTTY private key to the OpenSSH authenticator agent.

[ -z "$1" ] && echo "Usage: $(basename "$0") PPK_FILE" && exit

file=~/`basename $0`.tmp
trap "rm -v $file" EXIT
echo -n "Password: "
read -s pwd
echo

echo $pwd | puttygen -P -q -O private-openssh $1 -o $file
ssh-add $file
