#!/bin/bash

# Print one key/value pair.
# Inputs:
#   $1 - Key.
#   $2 - Value.
#
# Output:
#   Writes "KEY=VALUE" to stdout.
#
# Returns:
#   0 unless printf fails.
#
# Example:
#   output_kv status ok
function output_kv ()
{
    printf '%s=%s\n' "$1" "$2"
}

# Print values as a plain list.
# Inputs:
#   $@ - Values to print.
#
# Output:
#   Writes one value per line to stdout.
#
# Returns:
#   0 unless printf fails.
#
# Example:
#   output_list alpha beta gamma
function output_list ()
{
    printf '%s\n' "$@"
}

function _output_table_print_row ()
{
    local -n _output_print_widths_ref="$1"
    local cols="$2" i cell
    shift 2

    for ((i = 0; i < cols; i++)); do
        if (($# > 0)); then
            cell="$1"
            shift
        else
            cell=
        fi
        printf '%-*s' "${_output_print_widths_ref[i]}" "$cell"
        if (( i < cols - 1 )); then
            printf '  '
        fi
    done
    printf '\n'
}

function _output_table_print_separator ()
{
    local -n _output_sep_widths_ref="$1"
    local cols="$2" i j

    for ((i = 0; i < cols; i++)); do
        for ((j = 0; j < _output_sep_widths_ref[i]; j++)); do
            printf '-'
        done
        if (( i < cols - 1 )); then
            printf '  '
        fi
    done
    printf '\n'
}

# Print an aligned text table.
# Inputs:
#   $1 - Name of the indexed header array.
#   $2 - Name of the indexed row array. Each row is a tab-separated string.
#
# Output:
#   Writes a header row, separator row, and data rows to stdout.
#
# Returns:
#   0 on success; 2 when no headers are provided.
#
# Example:
#   headers=(Name Age); rows=($'Ivan\t42'); output_table headers rows
function output_table ()
{
    local -n _output_table_headers_ref="$1"
    local -n _output_table_rows_ref="$2"
    local cols="${#_output_table_headers_ref[@]}" row i
    local -a widths cells

    if (( cols == 0 )); then
        printf 'output_table requires at least one header\n' >&2
        return 2
    fi

    for ((i = 0; i < cols; i++)); do
        widths[i]="${#_output_table_headers_ref[i]}"
    done

    for row in "${_output_table_rows_ref[@]}"; do
        IFS=$'\t' read -r -a cells <<< "$row"
        for ((i = 0; i < cols; i++)); do
            if (( ${#cells[i]} > widths[i] )); then
                widths[i]="${#cells[i]}"
            fi
        done
    done

    _output_table_print_row widths "$cols" "${_output_table_headers_ref[@]}"
    _output_table_print_separator widths "$cols"
    for row in "${_output_table_rows_ref[@]}"; do
        IFS=$'\t' read -r -a cells <<< "$row"
        _output_table_print_row widths "$cols" "${cells[@]}"
    done
}
