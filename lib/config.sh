#!/bin/bash

function _config_valid_key ()
{
    [[ "$1" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]
}

# Load a KEY=VALUE file into an associative array.
# Inputs:
#   $1 - Readable config file path.
#   $2 - Name of the associative array to populate.
#
# Output:
#   None; mutates the named array in the caller scope.
#
# Returns:
#   0 on success; 1 when the file cannot be read; 2 for malformed lines or
#   invalid keys.
#
# Example:
#   declare -A cfg; config_load app.conf cfg
function config_load ()
{
    local file="$1" line key value
    local -n _config_load_ref="$2"

    [[ -r "$file" ]] || return 1
    _config_load_ref=()

    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -z "$line" || "$line" == \#* ]] && continue
        [[ "$line" == *=* ]] || return 2
        key="${line%%=*}"
        value="${line#*=}"
        _config_valid_key "$key" || return 2
        _config_load_ref["$key"]="$value"
    done < "$file"
}

# Print a value from a config associative array.
# Inputs:
#   $1 - Name of the associative array.
#   $2 - Config key.
#   $3 - Optional default value when the key is missing.
#
# Output:
#   Writes the configured value, or the default when provided, to stdout.
#
# Returns:
#   0 when a value or default is printed; 1 when the key is missing and no
#   default is provided; 2 when the key is invalid.
#
# Example:
#   port=$(config_get cfg PORT 8080)
function config_get ()
{
    local -n _config_get_ref="$1"
    local key="$2"

    _config_valid_key "$key" || return 2

    if [[ "${_config_get_ref[$key]+x}" == x ]]; then
        printf '%s\n' "${_config_get_ref[$key]}"
        return 0
    fi

    if (($# >= 3)); then
        printf '%s\n' "$3"
        return 0
    fi

    return 1
}

# Set a value in a config associative array.
# Inputs:
#   $1 - Name of the associative array.
#   $2 - Config key.
#   $3 - Value to store.
#
# Output:
#   None; mutates the named array in the caller scope.
#
# Returns:
#   0 on success; 2 when the key is invalid.
#
# Example:
#   config_set cfg PORT 8080
function config_set ()
{
    local -n _config_set_ref="$1"
    local key="$2" value="$3"

    _config_valid_key "$key" || return 2
    _config_set_ref["$key"]="$value"
}
