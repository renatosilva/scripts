#!/bin/bash

description="
    Parse Options Prototype 2013.10.16
    Copyright (c) 2013 Renato Silva
    GNU GPLv2 licensed

    This script is supposed to parse command line arguments in a way that,
    even though its implementation is not trivial, it should be easy and
    smooth to use. This script is supposed to be sourced or embedded into
    the target client script. This is a prototype, the main step missing
    being the support for option descriptions in automated help text.
    Here is an example of what it would look like using this script:

    Client script foo.sh:
        options=(v=verbose r=recursive input-file=? quick)
        source parse-options
        parse_options \"\$@\"

        echo \"input file is \$inputfile\"
        [[ -n \"\$verbose\" ]] && echo \"this shall be verbose\"
        echo \"\${arguments[0]}\" # Non-option arguments, if any

    Now calling the script:
        $ foo.sh -vr --quick
        $ foo.sh --help
        $ foo.sh -v --input-file /path/to/file -r extra arguments"

show_option_help() {
    printf "%4s%-20s%s\n" " " "$1" "Option description not implemented."
    printf "%24s%s\n\n" " " "This is second line of option description."
}

show_help() {

    indentation="4"
    echo -e "$description\n\nOptions:"

    for option in "${options[@]}"; do
        option_var=${option#*=}
        option_name=${option%=$option_var}

        if [[ "$option_var" = "$option_name" ]]; then
            show_option_help "--$option_var"

        elif [[ "$option_var" = "?" ]]; then
            show_option_help "--$option_name=PARAM"

        else
            show_option_help "-$option_name, --$option_var"
        fi
    done
}

parse_options() {

    local short_option_vars
    local short_options
    local option_value

    arguments=()
    options+=(h=help)

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
                known_option_var=$(echo "$known_option_var" | tr -d "-")
                eval $known_option_var="$option_value"
                break

            elif [[ "$option" = -$known_option_name && "$known_option_var" != "?" ]]; then
                option_value="yes"
                known_option_var=$(echo "$known_option_var" | tr -d "-")
                eval $known_option_var="$option_value"
                break

            elif [[ "$option" = -$known_option_name && "$known_option_var" = "?" ]]; then
                eval option_value="\$$OPTIND"
                if [[ -z "$option_value" || "$option_value" = -* ]]; then
                    echo "You must specify a value for --$known_option_name."
                    exit 1
                fi
                OPTIND=$((OPTIND + 1))
                known_option_var=$(echo "$known_option_name" | tr -d "-")
                eval $known_option_var="$option_value"
                break

            elif [[ "$option" = -$known_option_name=* && "$known_option_var" = "?" ]]; then
                option_value=${option#*=}
                known_option_var=$(echo "$known_option_name" | tr -d "-")
                eval $known_option_var="$option_value"
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
            show_help
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
}

options=(
    f=foo
    b=bar
    foobar
    log-level=?
)

parse_options "$@"
[[ -n "$foo"      ]] && echo "foo was specified"
[[ -n "$bar"      ]] && echo "bar was specified"
[[ -n "$foobar"   ]] && echo "foobar was specified"
[[ -n "$loglevel" ]] && echo "log-level was specified as [$loglevel]"
for argument in "${arguments[@]}"; do
    echo "Argument: [$argument]"
done
