#!/bin/bash

if test -z "${1}"; then tee <<done-usage

    Windows Console Converter 2016.4.30
    Copyright (c) 2016 Renato Silva
    GNU GPLv2 licensed

    This script executes the specified Windows console program and converts
    its output from the OEM code page to the encoding specified by the LANG
    environment variable.

done-usage
exit 1; fi

source="$(cat /proc/registry/HKEY_LOCAL_MACHINE/SYSTEM/CurrentControlSet/Control/Nls/CodePage/OEMCP 2>/dev/null)"
target="${LANG##${LANG/.*/.}}"
original="$("${@}" 2>&1)"
result=${?}
converted=$(iconv -s ${source:+--from-code cp${source}} ${target:+--to-code ${target}} <<<"${original}" 2>/dev/null)
test ${?} -eq 0 && echo "${converted}" || echo "${original}"
exit ${result}
