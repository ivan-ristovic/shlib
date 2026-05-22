#!/bin/bash

# Test whether a variable is defined.
# Inputs:
#   $1 - Variable name.
#
# Output:
#   None.
#
# Returns:
#   0 when the variable is defined, even if empty; 1 otherwise.
#
# Example:
#   if env_defined HOME; then printf '%s\n' "$HOME"; fi
function env_defined ()
{
    [[ "${!1+x}" == x ]]
}

# Test whether a variable is defined and non-empty.
# Inputs:
#   $1 - Variable name.
#
# Output:
#   None.
#
# Returns:
#   0 when the variable exists and is not empty; 1 otherwise.
#
# Example:
#   env_set API_TOKEN || printf 'missing token\n' >&2
function env_set ()
{
    env_defined "$1" && [[ -n "${!1}" ]]
}

# Require environment variables to be defined and non-empty.
# Inputs:
#   $@ - Variable names to check.
#
# Output:
#   Writes one missing-variable line to stderr for each unset or empty variable.
#
# Returns:
#   0 when every variable is set; 1 when any variable is missing or empty.
#
# Example:
#   env_require HOME USER || exit 1
function env_require ()
{
    local name _env_require_missing=0

    for name in "$@"; do
        if ! env_set "$name"; then
            printf 'missing environment variable: %s\n' "$name" >&2
            _env_require_missing=1
        fi
    done

    return "$_env_require_missing"
}

# Set and export a default value when a variable is unset or empty.
# Inputs:
#   $1 - Variable name.
#   $2 - Default value.
#
# Output:
#   None; assigns and exports the named variable when needed.
#
# Returns:
#   0 unless assignment or export fails.
#
# Example:
#   env_default EDITOR vi
function env_default ()
{
    local _env_default_name="$1" _env_default_value="$2"

    if ! env_set "$_env_default_name"; then
        printf -v "$_env_default_name" '%s' "$_env_default_value"
        export "${_env_default_name?}"
    fi
}

# Interpret a named variable as a boolean flag.
# Inputs:
#   $1 - Variable name.
#
# Output:
#   None.
#
# Returns:
#   0 for "1", "true", "yes", "y", or "on" ignoring case; 1 for all other
#   values and unset variables.
#
# Example:
#   if env_bool SHLIB_VERBOSE; then set -x; fi
function env_bool ()
{
    local _env_bool_value="${!1:-}"
    _env_bool_value="${_env_bool_value,,}"

    case "$_env_bool_value" in
        1|true|yes|y|on)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Load simple dotenv assignments into shell variables and export them.
# Inputs:
#   $1 - Readable dotenv file path with KEY=VALUE lines.
#
# Output:
#   None; assigns and exports variables in the current shell.
#
# Returns:
#   0 on success; 1 when the file cannot be read or contains malformed input.
#
# Example:
#   env_load_dotenv .env
function env_load_dotenv ()
{
    local _env_load_file="$1" _env_load_line _env_load_key _env_load_value

    [[ -r "$_env_load_file" ]] || return 1

    while IFS= read -r _env_load_line || [[ -n "$_env_load_line" ]]; do
        _env_load_line="${_env_load_line%$'\r'}"
        [[ -z "$_env_load_line" || "$_env_load_line" == \#* ]] && continue
        [[ "$_env_load_line" == *=* ]] || return 1

        _env_load_key="${_env_load_line%%=*}"
        _env_load_value="${_env_load_line#*=}"
        [[ "$_env_load_key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || return 1

        if [[ "$_env_load_value" == \"*\" && "$_env_load_value" == *\" ]]; then
            _env_load_value="${_env_load_value:1:${#_env_load_value}-2}"
        elif [[ "$_env_load_value" == \'*\' && "$_env_load_value" == *\' ]]; then
            _env_load_value="${_env_load_value:1:${#_env_load_value}-2}"
        fi

        printf -v "$_env_load_key" '%s' "$_env_load_value"
        export "${_env_load_key?}"
    done < "$_env_load_file"

    return 0
}
