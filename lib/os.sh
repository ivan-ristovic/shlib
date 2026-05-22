#!/bin/bash

# Print a normalized absolute path.
# Inputs:
#   $1 - Path to resolve with realpath.
#
# Output:
#   Writes the normalized absolute path to stdout.
#
# Returns:
#   0 on success; non-zero from realpath on failure.
#
# Example:
#   root=$(os_path_abs .)
function os_path_abs ()
{
    os_path "$(realpath "$1")"
}

# Print the final path component.
# Inputs:
#   $1 - Path.
#
# Output:
#   Writes the basename to stdout.
#
# Returns:
#   0 unless basename fails.
#
# Example:
#   file=$(os_path_file /tmp/archive.tar.gz)
function os_path_file ()
{
    basename "$1"
}

# Print the final path component without its last extension.
# Inputs:
#   $1 - Path.
#
# Output:
#   Writes the basename with the last extension removed.
#
# Returns:
#   0 unless basename fails.
#
# Example:
#   stem=$(os_path_file_noext /tmp/archive.tar.gz)
function os_path_file_noext ()
{
    basename -- "$1" ".${1##*.}"
}

# Print the last file extension.
# Inputs:
#   $1 - Path.
#
# Output:
#   Writes text after the last dot in the basename.
#
# Returns:
#   0 unless basename fails.
#
# Example:
#   ext=$(os_path_ext /tmp/archive.tar.gz)
function os_path_ext ()
{
    local filename
    filename=$(os_path_file "$1")
    echo "${filename##*.}"
}

# Print the full extension after the first dot.
# Inputs:
#   $1 - Path.
#
# Output:
#   Writes text after the first dot in the basename.
#
# Returns:
#   0 unless basename fails.
#
# Example:
#   ext=$(os_path_ext_full /tmp/archive.tar.gz)
function os_path_ext_full ()
{
    local filename
    filename=$(os_path_file "$1")
    echo "${filename#*.}"
}

# Print the normalized parent directory.
# Inputs:
#   $1 - Path.
#
# Output:
#   Writes the normalized parent path to stdout.
#
# Returns:
#   0 unless dirname fails.
#
# Example:
#   parent=$(os_path_par /tmp//logs/app.log)
function os_path_par ()
{
    os_path "$(dirname "$1")"
}

# Normalize repeated slashes in a path.
# Inputs:
#   $1 - Path string.
#
# Output:
#   Writes a path with repeated slash components collapsed.
#
# Returns:
#   0 unless printf fails.
#
# Example:
#   clean=$(os_path /tmp///logs/app.log)
function os_path ()
{
    local path=$1 dir

    if [[ $path =~ ^[^/]+$ ]]; then
        dir=.
    elif [[ $path =~ ^/+$ ]]; then
        dir=/
    else
        local IFS=/ i
        local -a dir_a
        read -ra dir_a <<< "$path"
        dir="${dir_a[0]}"
        for ((i=1; i < ${#dir_a[@]}; i++)); do
            [[ ${dir_a[i]} ]] && dir="$dir/${dir_a[i]}"
        done
    fi

    [[ $dir ]] && printf '%s\n' "$dir"
}
