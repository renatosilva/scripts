#!/bin/bash

# SSL Certificate 2012.10.7
# Copyright (C) 2012 Renato Silva
# GNU GPLv2 licensed

[[ -z "$2" ]] && echo "Usage: $0 <common name> <cert name>" && exit
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/CN=$1" -keyout "$2"  -out "$2"
