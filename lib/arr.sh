#!/bin/bash

# Print each element from a named Bash array.
# Inputs:
#   $1 - Name of an indexed or associative array variable.
#
# Output:
#   Writes one array element per line to stdout.
#
# Returns:
#   0 unless printf fails or the variable name is invalid.
#
# Example:
#   colors=(red green); arr_print colors
function arr_print ()
{
    local -n _arr_print_ref="$1"
    printf '%s\n' "${_arr_print_ref[@]}"
}

# Append values to a named Bash array.
# Inputs:
#   $1 - Name of an indexed array variable.
#   $@ - Values to append after the array name.
#
# Output:
#   None; mutates the named array in the caller scope.
#
# Returns:
#   0 unless the variable name is invalid.
#
# Example:
#   colors=(red); arr_append colors green blue
function arr_append ()
{
    local -n _arr_append_ref="$1"
    shift
    _arr_append_ref+=("$@")
}

# Print the number of elements in a named Bash array.
# Inputs:
#   $1 - Name of an indexed or associative array variable.
#
# Output:
#   Writes the element count to stdout.
#
# Returns:
#   0 unless printf fails or the variable name is invalid.
#
# Example:
#   count=$(arr_size colors)
function arr_size ()
{
    local -n _arr_size_ref="$1"
    printf '%s\n' "${#_arr_size_ref[@]}"
}

# Print arguments in reverse order.
# Inputs:
#   $@ - Values to reverse.
#
# Output:
#   Writes one value per line in reverse argument order.
#
# Returns:
#   0 unless printf fails.
#
# Example:
#   arr_reverse one two three
function arr_reverse ()
{
    local -a arr=("$@")
    local i
    for ((i=${#arr[@]} - 1; i >= 0; i--)); do
        printf '%s\n' "${arr[i]}"
    done
}

# Print unique non-empty arguments.
# Inputs:
#   $@ - Values to de-duplicate.
#
# Output:
#   Writes one unique non-empty value per line. Output order follows Bash
#   associative-array iteration order.
#
# Returns:
#   0 unless printf fails.
#
# Example:
#   arr_uniq alpha beta alpha ""
function arr_uniq ()
{
    declare -A tmp_array
    local i

    for i in "$@"; do
        [[ $i ]] && IFS=" " tmp_array["${i:- }"]=1
    done

    printf '%s\n' "${!tmp_array[@]}"
}

# Print one random argument.
# Inputs:
#   $@ - Candidate values; pass at least one value.
#
# Output:
#   Writes one selected value to stdout.
#
# Returns:
#   0 unless no candidates are passed or printf fails.
#
# Example:
#   mirror=$(arr_rand_elem mirror1 mirror2 mirror3)
function arr_rand_elem ()
{
    local arr=("$@")
    printf '%s\n' "${arr[RANDOM % $#]}"
}
