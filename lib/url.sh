#!/bin/bash

# Percent-encode a URL component.
# Inputs:
#   $1 - Text to encode.
#
# Output:
#   Writes encoded text to stdout.
#
# Returns:
#   0 unless printf fails.
#
# Example:
#   encoded=$(url_encode "hello world")
function url_encode ()
{
    local LC_ALL=C char i
    local value="${1:-}"

    for ((i = 0; i < ${#value}; i++)); do
        char="${value:i:1}"
        case "$char" in
            [a-zA-Z0-9:/.~_-])
                printf '%s' "$char"
                ;;
            *)
                printf '%%%02X' "'$char"
                ;;
        esac
    done
    printf '\n'
}

# Decode percent-encoded URL text.
# Inputs:
#   $1 - Encoded text.
#
# Output:
#   Writes decoded text to stdout.
#
# Returns:
#   0 unless printf fails.
#
# Example:
#   decoded=$(url_decode "hello%20world")
function url_decode ()
{
    local value="${1:-}"
    value="${value//+/ }"
    printf '%b\n' "${value//%/\\x}"
}

# Print a decoded query-string value by key.
# Inputs:
#   $1 - Key to find.
#   $2 - Query string, with or without a leading question mark.
#
# Output:
#   Writes the decoded value to stdout when found.
#
# Returns:
#   0 when the key is found; 1 otherwise.
#
# Example:
#   page=$(url_query_get page "?page=2&q=term")
function url_query_get ()
{
    local key="$1" query="${2#\?}" pair raw_key raw_value decoded_key
    local -a pairs

    IFS='&' read -ra pairs <<< "$query"
    for pair in "${pairs[@]}"; do
        [[ -z "$pair" ]] && continue
        raw_key="${pair%%=*}"
        raw_value=
        if [[ "$pair" == *=* ]]; then
            raw_value="${pair#*=}"
        fi
        decoded_key="$(url_decode "$raw_key")"
        if [[ "$decoded_key" == "$key" ]]; then
            url_decode "$raw_value"
            return 0
        fi
    done

    return 1
}

# Add or replace a query-string value.
# Inputs:
#   $1 - Key to set.
#   $2 - Value to set.
#   $3 - Query string, with or without a leading question mark.
#
# Output:
#   Writes the updated query string to stdout, preserving a leading question
#   mark when present.
#
# Returns:
#   0 unless encoding or printf fails.
#
# Example:
#   query=$(url_query_set page 3 "$query")
function url_query_set ()
{
    local key="$1" value="$2" query="$3" prefix="" pair raw_key decoded_key encoded_key encoded_value found=0
    local -a pairs output

    if [[ "$query" == \?* ]]; then
        prefix='?'
        query="${query#\?}"
    fi

    encoded_key="$(url_encode "$key")"
    encoded_value="$(url_encode "$value")"

    IFS='&' read -ra pairs <<< "$query"
    for pair in "${pairs[@]}"; do
        [[ -z "$pair" ]] && continue
        raw_key="${pair%%=*}"
        decoded_key="$(url_decode "$raw_key")"
        if [[ "$decoded_key" == "$key" ]]; then
            if (( found == 0 )); then
                output+=("${encoded_key}=${encoded_value}")
                found=1
            fi
        else
            output+=("$pair")
        fi
    done

    if (( found == 0 )); then
        output+=("${encoded_key}=${encoded_value}")
    fi

    local IFS='&'
    printf '%s%s\n' "$prefix" "${output[*]}"
}
