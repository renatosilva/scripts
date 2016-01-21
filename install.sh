#!/bin/bash

profile=(aliases.sh)
remote=(colormake::'https://github.com/renatosilva/colormake/raw/master/colormake.sh'
        easyoptions::'https://github.com/renatosilva/easyoptions/raw/master/easyoptions'
        easyoptions.rb::'https://github.com/renatosilva/easyoptions/raw/master/ruby/easyoptions.rb'
        easyoptions.sh::'https://github.com/renatosilva/easyoptions/raw/master/bash/easyoptions.sh'
        vimcat::'https://github.com/rkitover/vimpager/raw/b3bb583/vimcat'
        vimpager::'https://github.com/rkitover/vimpager/raw/b3bb583/vimpager')

if [[ $(uname -or) = 1.*Msys ]]
    then local=(minget colordiff)
    else local=(bacon-crypt bzrcheck bzrgrep bzrtags colordiff csvt launchtohub numpass randpass)
fi

case "${1}" in --remove)
    for script in "${profile[@]}"; do rm -vf "/etc/profile.d/${script}"; done
    for script in "${local[@]}";   do rm -vf "/usr/local/bin/${script}"; done
    for script in "${remote[@]}";  do rm -vf "/usr/local/bin/${script%%::*}"; done ;;
*)
    for script in "${profile[@]}"; do install -Dv "$(dirname "$0")/${script}"* "/etc/profile.d/${script}"; done
    for script in "${local[@]}";   do install -Dv "$(dirname "$0")/${script}"* "/usr/local/bin/${script}"; done; echo
    for script in "${remote[@]}";  do wget -nv --no-check-certificate -O "/usr/local/bin/${script%%::*}" "${script#*::}" && chmod +x "/usr/local/bin/${script%%::*}"; done
esac
