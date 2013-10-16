#!/bin/bash

# MinGW-Get Packages Helper 2013.10.16
# Copyright (c) 2012, 2013 Renato Silva
# GNU GPLv2 licensed

get_component_version() {
    component_version=$(mingw-get show "$1-$2" | grep '^Installed Version' | awk -F'  ' '{print $2}')
}

# List packages
if [[ -z "$1" ]]; then
    mingw-get list
    exit
fi

# Extra argument
if [[ -n "$4" ]] || [[ -n "$3" && "$2" = "--full" ]]; then
    [[ -n "$4" ]] && shift
    echo "Extra argument: $3"
    exit
fi

# Full search
if [[ "$2" = "--full" ]]; then
    mingw-get list | grep --color -C4 "$1"
    exit
fi

# Invalid index
if [[ -n "$2" && ! "$2" =~ "^[0-9]+$" ]]; then
    echo "Invalid index: $2"
    exit
fi

# Name search
packages=($(mingw-get list | grep ^Package | grep -i "$1" | sed -E s/"Package: (\S*).*"/"\\1"/))
if [[ -z "$2" ]]; then
    count="0"
    for package in "${packages[@]}"; do
        count=$((count + 1))
        printf '%#3d %s\n' "$count" "$package" | grep -i --color "$1"
    done
    exit
fi

# Action by index
action="$3"
[[ -z "$action" ]] && action="this:installed"
count="0"
for package in "${packages[@]}"; do
    count=$((count + 1))
    if [[ "$count" == "$2" ]]; then

        # Execute specified action
        if [[ "$action" != "show" && "$action" != "this:installed" ]]; then
            mingw-get "$action" "$package"
            exit
        fi

        package_info=$(mingw-get show "$package")
        components=$(echo "$package_info" | grep '^Components' | sed s/"Components: "/""/)
        IFS=", " read -a components <<< "$components"

        # Show whether the package is installed
        if [[ "$action" = "this:installed" ]]; then
            installed=()
            available=()
            for component in "${components[@]}"; do
                get_component_version "$package" "$component"
                [[ "$component_version" != "none" ]] && installed+=("$component") || available+=("$component")
            done
            installed=$(echo "${installed[@]}" | sed "s/ /, /g")
            available=$(echo "${available[@]}" | sed "s/ /, /g")
            [[ -z "$installed" ]] && installed="none"
            [[ -z "$available" ]] && available="none"
            echo "Package: $package"
            echo "Installed components: $installed"
            echo "Available components: $available"
            exit
        fi

        # Show package and component information
        components_info=""
        for component in "${components[@]}"; do
            get_component_version "$package" "$component"
            [[ "$component_version" != "none" ]] && component_info="installed: $component_version" || component_info="not installed"
            component=$(printf "%-4s" "$component")
            components_info="$components_info\n    $component is $component_info"
        done
        echo "$package_info" | sed -E s/"^(Components:.*)$"/"\\1$components_info"/
        exit
    fi
done
echo "No package found at search index $2"
