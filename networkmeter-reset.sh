#!/bin/bash

# Network Meter Reset 2013.10.5
# Copyright (c) 2013 Renato Silva
# GNU GPLv2 licensed

[[ -z "$1" ]] && echo "Usage: $0 --sure" && exit

taskkill //f //im sidebar.exe
sed -i -E s/'(saveTotal(Send|Received|Tot))=.*'/'\1="0"'/g ~/"AppData/Local/Microsoft/Windows Sidebar/Settings.ini"
"/c/Programs/Windows Sidebar/sidebar.exe" &
