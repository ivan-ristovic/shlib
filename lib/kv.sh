#!/bin/bash

function _kv_valid_key ()
{
    [[ "$1" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]
}

# Print a value from a KEY=VALUE file.
# Inputs:
#   $1 - Key name.
#   $2 - Readable key/value file path.
#
# Output:
#   Writes the value for the first matching key to stdout.
#
# Returns:
#   0 when the key is found; 1 when the file or key is missing; 2 when the key
#   name is invalid.
#
# Example:
#   value=$(kv_get PORT app.env)
function kv_get ()
{
    local key="$1" file="$2" line line_key

    _kv_valid_key "$key" || return 2
    [[ -r "$file" ]] || return 1

    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -z "$line" || "$line" == \#* || "$line" != *=* ]] && continue
        line_key="${line%%=*}"
        if [[ "$line_key" == "$key" ]]; then
            printf '%s\n' "${line#*=}"
            return 0
        fi
    done < "$file"

    return 1
}

# Test whether a key exists in a KEY=VALUE file.
# Inputs:
#   $1 - Key name.
#   $2 - Readable key/value file path.
#
# Output:
#   None.
#
# Returns:
#   0 when the key exists; 1 when it does not or the file is unreadable; 2 when
#   the key name is invalid.
#
# Example:
#   if kv_has TOKEN .env; then echo configured; fi
function kv_has ()
{
    kv_get "$1" "$2" >/dev/null
}

# Print valid keys from a KEY=VALUE file.
# Inputs:
#   $1 - Readable key/value file path.
#
# Output:
#   Writes one valid key per line, ignoring comments, blank lines, and invalid
#   keys.
#
# Returns:
#   0 on success; 1 when the file is unreadable.
#
# Example:
#   kv_keys app.env
function kv_keys ()
{
    local file="$1" line key

    [[ -r "$file" ]] || return 1

    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -z "$line" || "$line" == \#* || "$line" != *=* ]] && continue
        key="${line%%=*}"
        _kv_valid_key "$key" && printf '%s\n' "$key"
    done < "$file"

    return 0
}

# Add or replace a key in a KEY=VALUE file.
# Inputs:
#   $1 - Key name.
#   $2 - Value to store.
#   $3 - File path to create or update.
#
# Output:
#   None; writes the updated file in place.
#
# Returns:
#   0 on success; 1 on file update failure; 2 when the key name is invalid.
#
# Example:
#   kv_set PORT 8080 app.env
function kv_set ()
{
    local key="$1" value="$2" file="$3" tmp line line_key found=0

    _kv_valid_key "$key" || return 2

    tmp="$(mktemp "${file}.tmp.XXXXXX")" || return 1

    {
        if [[ -f "$file" ]]; then
            while IFS= read -r line || [[ -n "$line" ]]; do
                if [[ "$line" == *=* ]]; then
                    line_key="${line%%=*}"
                    if [[ "$line_key" == "$key" ]]; then
                        if (( found == 0 )); then
                            printf '%s=%s\n' "$key" "$value"
                            found=1
                        fi
                        continue
                    fi
                fi
                printf '%s\n' "$line"
            done < "$file"
        fi

        if (( found == 0 )); then
            printf '%s=%s\n' "$key" "$value"
        fi
    } > "$tmp" || {
        rm -f -- "$tmp"
        return 1
    }

    mv -- "$tmp" "$file"
}
