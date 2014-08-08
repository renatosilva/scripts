#!/bin/bash

# DNS Dynamic Update 2014.8.8
# Copyright (c) 2013 Renato Silva
# GNU GPLv2 licensed

[[ -z "$3" ]] && echo "Usage: $(basename "$0") <hostname> <email> <password file>" && exit

interval=$((60*30))
while true; do
    wget "http://ifconfig.me/ip"
    email=$(echo "$2" | sed "s/@/%40/")
    password=$(cat "$3")
    wget --delete-after --no-check-certificate "https://$email:$password@www.dnsdynamic.org/api/?hostname=$1&myip=$(cat ip)"
    rm ip
    sleep $interval
done
