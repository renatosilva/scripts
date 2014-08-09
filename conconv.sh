#!/bin/bash

# Encoding Converter For Console Programs 2014.8.8
# Copyright (c) 2012, 2014 Renato Silva
# GNU GPLv2 licensed

# In order to convert output of console programs, create copies of this script
# named as conconv.encoding, where encoding is the source encoding. Then make
# symlinks to that in the same directory, named as the target program but
# without the exe extension. Now make these symlinks available before the
# original executables in system path. Target encoding is determined by the LANG
# environment variable, or by iconv if that is missing.

# For example, if ipconfig is a symlink to conconv.cp850 and the LANG
# environment variable is set to pt_BR.UTF-8, then output of ipconfig.exe would
# be converted from cp850 to UTF-8.

to="${LANG##*.}"
this=$(readlink -e "$0")
$(basename "$0").exe "$@" 2>&1 | iconv -f "${this#*.}" ${to:+-t $to}
