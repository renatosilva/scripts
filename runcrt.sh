#!/bin/bash

# Run MSVCRT 2012.12.10
# Copyright (c) 2012 Renato Silva
# GNU GPLv2 licensed

# This programs is used to hide the TZ environment variable set in MSYS from
# MSVCRT applications, since MSVCRT has its own conflicting syntax for that
# variable. In order to use this program, make symlinks to this script with
# the name of each MSVCRT program, excluding the exe extension, then make these
# symlinks available before the original executables in system path.

env -u TZ $(basename "$0").exe "$@"
