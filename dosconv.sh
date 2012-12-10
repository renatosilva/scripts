#!/bin/bash

# DOS Encoding Converter 2012.12.10
# Copyright (c) 2012 Renato Silva
# GNU GPLv2 licensed

# In order to convert output of DOS programs, make symlinks to this script with
# the name of each program, excluding the exe extension, then make these
# symlinks available before the original executables in system path.

$(basename "$0").exe "$@" 2>&1 | iconv -f cp850 -t cp1252
