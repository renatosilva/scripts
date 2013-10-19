#!/bin/bash

## Parse Options 2013.10.19
## Copyright (c) 2013 Renato Silva
## GNU GPLv2 licensed
##
## This script is supposed to parse command line arguments in a way that,
## even though its implementation is not trivial, it should be easy and
## smooth to use. For using this script, simply document your target script
## using double-hash comments, like this:
##
##     ## Program Name v1.0
##     ## Copyright (C) Someone
##     ##
##     ## This program does something. Usage:
##     ##     @#script.name [option]
##     ##
##     ## Options:
##     ##     --boolean, -b        This option will get stored as boolean=yes.
##     ##                          Long version must come first.
##     ##
##     ##     --another-boolean    This will get stored as another_boolean=yes.
##     ##
##     ##     ---some-value=VALUE  This will get stored as some_value=<value>,
##     ##                          equal sign can be replaced with space.
##     ##
##     ##     --help, -h           All client scripts have this by default,
##     ##                          it shows this double-hash documentation.
##
## The above comments work both as source code documentation and as help
## text, as well as define the options supported by your script. Parsing
## of the options from such documentation is quite slow, but at least there
## is not any duplication of the options specification. The string @#script.name
## will be replaced with the actual script name.
##
## After writing your documentation, you simply source this script. Then all
## command line options will get parsed into the corresponding variables,
## as described above. You can then check their values for reacting to them.
##
## In fact, this script is an example of itself. You are seeing this help
## message either because you are reading the source code, or you have called
## the script in command line with the --help option.

parse_options() {

    local short_option_vars
    local short_options
    local option_value

    arguments=()
    options=(h=help)

    documentation="$(grep "^##" "$0")(no-trim)"
    documentation=$(echo "$documentation" | sed -r "s/## ?//" | sed -r "s/@script.name/$(basename "$0")/g" | sed "s/@#/@/g")
    documentation=${documentation%(no-trim)}

    while read -r line; do
        case "$line" in
            --*," "-*)  option=$(echo "$line" | awk -F'(--|, -| )'  '{ print $3"="$2 }') ;;
            --*=*)      option=$(echo "$line" | awk -F'(--|=| )'    '{ print $2"=?" }') ;;
            --*" "*)    option=$(echo "$line" | awk -F'(--| )'      '{ print $2 }') ;;
            *)          continue ;;
        esac
        options+=("$option")
    done <<< "$documentation"

    for option in "${options[@]}"; do
        option_var=${option#*=}
        option_name=${option%=$option_var}
        if [[ "${#option_name}" = "1" ]]; then
            short_options="${short_options}${option_name}"
            if [[ "${#option_var}" > "1" ]]; then
                short_option_vars+=("$option_var")
            fi
        fi
    done

    while getopts ":${short_options}-:" option; do
        option="${option}${OPTARG}"
        option_value=""

        for known_option in "${options[@]}" "${short_option_vars[@]}"; do
            known_option_var=${known_option#*=}
            known_option_name=${known_option%=$known_option_var}

            if [[ "$option" = "$known_option_name" ]]; then
                option_value="yes"
                known_option_var=$(echo "$known_option_var" | tr "-" "_")
                eval export $known_option_var="$option_value"
                break

            elif [[ "$option" = -$known_option_name && "$known_option_var" != "?" ]]; then
                option_value="yes"
                known_option_var=$(echo "$known_option_var" | tr "-" "_")
                eval export $known_option_var="$option_value"
                break

            elif [[ "$option" = -$known_option_name && "$known_option_var" = "?" ]]; then
                eval option_value="\$$OPTIND"
                if [[ -z "$option_value" || "$option_value" = -* ]]; then
                    echo "You must specify a value for --$known_option_name."
                    exit 1
                fi
                OPTIND=$((OPTIND + 1))
                known_option_var=$(echo "$known_option_name" | tr "-" "_")
                eval export $known_option_var="$option_value"
                break

            elif [[ "$option" = -$known_option_name=* && "$known_option_var" = "?" ]]; then
                option_value=${option#*=}
                known_option_var=$(echo "$known_option_name" | tr "-" "_")
                eval export $known_option_var="$option_value"
                break

            elif [[ "$option" = -$known_option_name=* && "$known_option_var" != "?" ]]; then
                option_value=${option#*=}
                echo "Error: --$known_option_name does not accept a value."
                exit 1
            fi
        done

        if [[ -z "$option_value" ]]; then
            option=$(echo $option | sed "s/\?//")
            echo "Unrecognized option: -$option."
            exit 1
        fi

        if [[ -n "$help" ]]; then
            echo "$documentation"
            exit
        fi
    done

    local next_is_value=""
    for argument in "$@"; do
        if [[ "$argument" = -* ]]; then
            for known_option in "${options[@]}"; do
                known_option_var=${known_option#*=}
                known_option_name=${known_option%=$known_option_var}
                if [[ "$known_option_var" = "?" && "$argument" = --$known_option_name ]]; then
                    next_is_value="yes"
                    break
                fi
            done
        else
            [[ -z "$next_is_value" ]] && arguments+=("$1")
            next_is_value=""
        fi
        shift
    done
    export arguments options
}

parse_options "$@"
