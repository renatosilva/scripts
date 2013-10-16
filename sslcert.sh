#!/bin/bash

# SSL Certificate 2013.10.16
# Copyright (C) 2012, 2013 Renato Silva
# GNU GPLv2 licensed

[[ -z "$2" ]] && echo "Usage: $(basename "$0") <common name> <cert name>" && exit
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/CN=$1" -keyout "$2"  -out "$2"
