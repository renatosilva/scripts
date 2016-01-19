#!/bin/bash

##
##     Renato Silva Scripts
##     Copyright (C) 2009-2014 Renato Silva
##     GNU GPLv2 licensed
##
## Usage: @script.name [options]
##
##     -r, --remove        Remove the scripts instead of installing them.
##     -l, --local         Do not install the third-party downloads.
##
##         --where=PATH    Install scripts to PATH rather than /usr/local/bin,
##                         or remove them from there. This option does not
##                         affect scripts that need to be installed into
##                         /etc/profile.d. Requires --system.
##
##         --system=NAME   Set system type manually, determining which scripts
##                         will be installed. Supported systems are "unix",
##                         "msys" and "msys2".
##
##         --to-msys=ROOT  Shorthand for --system=msys --where=ROOT/local/bin.
##                         ROOT is a valid MSYS root.
##

eayoptions_url_base='https://github.com/renatosilva/easyoptions/raw/master'
vimpager_url_base='https://github.com/rkitover/vimpager/raw/b3bb583'
vpaste_url_base='http://vpaste.net/vpaste'

all=(colormake::'https://github.com/renatosilva/colormake/raw/master/colormake.sh'
     bacon-crypt
     bzrcheck
     bzrgrep
     bzrtags
     colordiff
     csvt
     numpass
     randpass)

windows=(backup
        ivona-speak
        winclean)

msys1=(easyoptions::"${eayoptions_url_base}/easyoptions"
       easyoptions.rb::"${eayoptions_url_base}/ruby/easyoptions.rb"
       easyoptions.sh::"${eayoptions_url_base}/bash/easyoptions.sh"
       vimcat::"${vimpager_url_base}/vimcat"
       vimpager::"${vimpager_url_base}/vimpager"
       conconv-msys1
       minget
       msys2-msys.bat
       runcrt
       tz-brazil)

msys2=(vpaste::"${vpaste_url_base}"
       conconv-msys2
       http-shutdown
       launchtohub)

unix=(easyoptions::"${eayoptions_url_base}/easyoptions"
      easyoptions.rb::"${eayoptions_url_base}/ruby/easyoptions.rb"
      easyoptions.sh::"${eayoptions_url_base}/bash/easyoptions.sh"
      vimcat::"${vimpager_url_base}/vimcat"
      vimpager::"${vimpager_url_base}/vimpager"
      vpaste::"${vpaste_url_base}"
      launchtohub)

dosconv() {
    read input
    msys_encoding="${LANG##*.}"
    dos_encoding=$(cmd //c chcp)
    dos_encoding="cp${dos_encoding##*\ }"
    echo "$input" | iconv -f "$dos_encoding" ${msys_encoding:+-t $msys_encoding}
}

winlink() {
    if [[ -z "$remove" && ! -e "$where/$1" ]]; then
        cd "$where"
        cmd.exe //c mklink "$1" "$2" | dosconv
        [[ "$1" = cmd ]] && hash cmd
        cd - > /dev/null
    fi
    [[ -n "$remove" && -e "$where/$1" ]] && rm -vf "$where/$1"
}

winlinks() {
    if [[ $system = msys* ]]; then
        [[ -z "$remove" && ! -e "$where/cmd" ]] && printf "\n${title_format:-%s}\n" "Creating symlinks"
        for link in cmd attrib ipconfig net ping reg schtasks shutdown taskkill; do winlink "$link" conconv.cp850; done
        [[ $system = msys ]] && for link in bzr python ruby; do winlink "$link" runcrt; done
        winlink speak ivona-speak
    fi
}

download() {
    file="$2/$3"
    host="${1#*//}"
    host="${host%%/*}"
    wget -q --no-check-certificate -O "$file" "$1" && chmod +x "$file"
    case "$?" in
        0) printf "%s -> $2/$3\n" "$host" ;;
        *) printf "${error_format:-%s} failed downloading and installing $3\n" "Error:" >&2 ;;
    esac
}

# Colors and EasyOptions
[[ -t 1 ]] && title_format="\e[0;32m%s\e[0m"
[[ -t 2 ]] && error_format="\e[1;31m%s\e[0m"
if ! which easyoptions > /dev/null 2>&1; then
    download "$eayoptions_url_base/ruby/easyoptions.rb" /tmp "easyoptions.rb" > /dev/null || rm /tmp/easyoptions.rb
    download "$eayoptions_url_base/easyoptions"         /tmp "easyoptions"    > /dev/null || rm /tmp/easyoptions
    PATH="/tmp:$PATH"
fi
source easyoptions || exit

# Install to MSYS from a non-MSYS environment
if [[ -n "$to_msys" ]]; then
    if [[ -n "$system" || -n "$where" ]]; then
        [[ -n "$system" ]] && echo "Ambiguous options specified: --to_msys implies --system=msys."
        [[ -n "$where"  ]] && echo "Ambiguous options specified: --to_msys implies --where=$to_msys."
        exit 1
    fi
    if [[ ! -f "$to_msys/bin/msys-1.0.dll" ]]; then
        echo "Invalid MSYS root \"$to_msys\"."
        exit 1
    fi
    where="$to_msys/local/bin"
    system="msys"
fi

# Target system
if [[ -z "$system" ]]; then
    if [[ -n "$where" ]]; then
        echo "No target system specified, see --help."
        exit 1
    fi
    case $(uname -or) in
        1.*Msys) system="msys" ;;
        2.*Msys) system="msys2" ;;
        *) system="unix"
    esac
elif [[ "$system" != unix && "$system" != msys && "$system" != msys2 ]]; then
    echo "Unrecognized system type \"$system\"."
    exit 1
fi

# Prepare
default_location="/usr/local/bin"
where="${where:-$default_location}"
mkdir -p "$where"
case $system in
    unix)  scripts="${all[@]} ${unix[@]}" ;;
    msys)  scripts="${all[@]} ${windows[@]} ${msys1[@]}" ;;
    msys2) scripts="${all[@]} ${windows[@]} ${msys2[@]}" ;;
esac

# Deploy
from=$(dirname "$0")
if [[ -z "$remove" ]]; then
    printf "${title_format:-%s}\n" "Installing local scripts"
    for script in $scripts; do
        case "$script" in
            *::http*)       remote_scripts+=("$script") ;;
            conconv-msys1)  cp -v "$from/conconv-msys1.sh" "$where/conconv.cp850" ;;
            conconv-msys2)  cp -v "$from/conconv-msys2.sh" "$where/conconv.cp850" ;;
            *)              cp -v "$from/$script"* "$where/$script" ;;
        esac
    done
    mkdir -p "$to_msys/etc/profile.d"
    cp -v "$from/aliases.sh" "$to_msys/etc/profile.d/aliases.sh"
    if [[ $system != msys2 ]]; then
        if [[ -n "$to_msys" || "$where" = "$default_location" ]]; then
            echo "Adding $default_location to Ruby library path"
            echo "export RUBYLIB=\"\$RUBYLIB:$default_location\"" > "$to_msys/etc/profile.d/rubylib.sh"
        else
            echo "Ignoring configuration of Ruby library path"
        fi
    fi
    if [[ -z "$local" && -n "${remote_scripts[0]}" ]]; then
        printf "\n${title_format:-%s}\n" "Installing remote scripts"
        for script in "${remote_scripts[@]}"; do
            download "${script#*::}" "${where}" "${script%%::*}"
        done
    fi
    winlinks
else
    winlinks
    for script in $scripts; do rm -vf "${where}/${script%%::*}"; done
    [[ $system != msys2 ]] && rm -vf "$to_msys/etc/profile.d/rubylib.sh"
    rm -vf "$to_msys/etc/profile.d/aliases.sh"
    rm -vf "$where/conconv.cp850"
fi
