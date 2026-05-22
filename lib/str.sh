#!/bin/bash

if [[ -n "${SHLIB_ROOT:-}" && -r "$SHLIB_ROOT/url.sh" ]]; then
    # shellcheck source=lib/url.sh
    source "$SHLIB_ROOT/url.sh"
fi

# Print the character count of a string.
# Inputs:
#   $1 - String to measure.
#
# Output:
#   Writes the Bash string length to stdout.
#
# Returns:
#   0 unless printf fails.
#
# Example:
#   length=$(str_len "hello")
function str_len ()
{
    printf "%s\\n" "${#1}"
}

# Format one value with printf.
# Inputs:
#   $1 - printf format string.
#   $2 - Input value.
#   $3 - Optional output variable name; pass "-" or omit it to print.
#
# Output:
#   Writes formatted text to stdout unless an output variable is provided.
#
# Returns:
#   0 unless printf fails or the output variable name is invalid.
#
# Example:
#   str_format "%04d" 7 padded
function str_format ()
{

    declare _format="$1" _input="$2" _return="${3:-}"

    # shellcheck disable=SC2059
    if [[ -n "${_return}" && "${_return}" != "-" ]]; then
        printf -v "${_return}" "${_format}" "${_input}"
    else
        printf "${_format}" "${_input}"
    fi
}

# Join arguments with a delimiter.
# Inputs:
#   $1 - Delimiter.
#   $2 - First value.
#   $@ - Additional values.
#
# Output:
#   Writes joined text to stdout without adding a trailing newline.
#
# Returns:
#   0 unless printf fails.
#
# Example:
#   csv=$(str_join "," alpha beta gamma)
function str_join ()
{
    local d=${1-} f=${2-}
    if shift 2; then
        printf %s "$f" "${@/#/$d}"
    fi
}

# Replace every literal occurrence in a string.
# Inputs:
#   $1 - Source string.
#   $2 - Pattern text to replace.
#   $3 - Replacement text.
#
# Output:
#   Writes the updated string to stdout.
#
# Returns:
#   0 unless printf fails.
#
# Example:
#   str_replace "hello world" world shell
function str_replace ()
{
    local str="$1"
    local pattern="$2"
    local replacement="$3"
    printf '%s\n' "${str//"$pattern"/"$replacement"}"
}

# Trim leading and trailing whitespace.
# Inputs:
#   $1 - String to trim.
#
# Output:
#   Writes the trimmed string to stdout.
#
# Returns:
#   0 unless printf fails.
#
# Example:
#   clean=$(str_trim "  value  ")
function str_trim ()
{
    : "${1#"${1%%[![:space:]]*}"}"
    : "${_%"${_##*[![:space:]]}"}"
    printf '%s\n' "$_"
}

# Remove all matching pattern occurrences from each value.
# Inputs:
#   $1 - Bash pattern to remove.
#   $@ - Values to process after the pattern.
#
# Output:
#   Writes one processed value per line.
#
# Returns:
#   0 unless printf fails.
#
# Example:
#   str_strip_a "-" "a-b-c"
function str_strip_a ()
{
    local pattern=$1
    shift
    printf '%s\n' "${@//$pattern}"
}

# Remove the first matching pattern occurrence from each value.
# Inputs:
#   $1 - Bash pattern to remove.
#   $@ - Values to process after the pattern.
#
# Output:
#   Writes one processed value per line.
#
# Returns:
#   0 unless printf fails.
#
# Example:
#   str_strip_f "-" "a-b-c"
function str_strip_f ()
{
    local pattern=$1
    shift
    printf '%s\n' "${@/$pattern}"
}

# Remove a matching prefix pattern from each value.
# Inputs:
#   $1 - Bash pattern to strip from the left.
#   $@ - Values to process after the pattern.
#
# Output:
#   Writes one processed value per line.
#
# Returns:
#   0 unless printf fails.
#
# Example:
#   str_strip_l "src/" "src/app.sh"
function str_strip_l ()
{
    local pattern=$1
    shift
    printf '%s\n' "${@##"$pattern"}"
}

# Remove a matching suffix pattern from each value.
# Inputs:
#   $1 - Bash pattern to strip from the right.
#   $@ - Values to process after the pattern.
#
# Output:
#   Writes one processed value per line.
#
# Returns:
#   0 unless printf fails.
#
# Example:
#   str_strip_r ".sh" "app.sh"
function str_strip_r ()
{
    local pattern=$1
    shift
    printf '%s\n' "${@%%"$pattern"}"
}

# Split a string on a delimiter.
# Inputs:
#   $1 - Delimiter string.
#   $* - Input text after the delimiter.
#
# Output:
#   Writes one field per line.
#
# Returns:
#   0 unless read or printf fails.
#
# Example:
#   str_split "::" "a::b::c"
function str_split ()
{
    local delim=$1 arr
    shift
    IFS=$'\n' read -d "" -r arr <<< "${@//"$delim"/$'\n'}"
    printf '%s\n' "${arr[@]}"
}

# Percent-encode text for a URL component.
# Inputs:
#   $@ - Arguments passed to url_encode.
#
# Output:
#   Writes encoded text to stdout.
#
# Returns:
#   The status from url_encode.
#
# Example:
#   encoded=$(str_url_encode "hello world")
function str_url_encode ()
{
    url_encode "$@"
}

# Decode percent-encoded URL text.
# Inputs:
#   $@ - Arguments passed to url_decode.
#
# Output:
#   Writes decoded text to stdout.
#
# Returns:
#   The status from url_decode.
#
# Example:
#   decoded=$(str_url_decode "hello%20world")
function str_url_decode ()
{
    url_decode "$@"
}

# Convert a string to lowercase.
# Inputs:
#   $1 - String to convert.
#
# Output:
#   Writes lowercase text to stdout.
#
# Returns:
#   0 unless printf fails.
#
# Example:
#   lower=$(str_to_lower "ABC")
function str_to_lower ()
{
    printf '%s\n' "${1,,}"
}

# Convert a string to uppercase.
# Inputs:
#   $1 - String to convert.
#
# Output:
#   Writes uppercase text to stdout.
#
# Returns:
#   0 unless printf fails.
#
# Example:
#   upper=$(str_to_upper "abc")
function str_to_upper ()
{
    printf '%s\n' "${1^^}"
}

# Test whether text contains a substring.
# Inputs:
#   $1 - Needle string.
#   $* - Text to search after the needle.
#
# Output:
#   None.
#
# Returns:
#   0 when the combined text contains the needle; 1 otherwise.
#
# Example:
#   str_contains error "$line"
function str_contains ()
{
    local needle=$1
    shift
    [[ "$*" == *"$needle"* ]]
}

# Test whether text starts with a prefix.
# Inputs:
#   $1 - Prefix string.
#   $* - Text to test after the prefix.
#
# Output:
#   None.
#
# Returns:
#   0 when the combined text starts with the prefix; 1 otherwise.
#
# Example:
#   str_starts_with "refs/" "$ref"
function str_starts_with ()
{
    local needle=$1
    shift
    [[ "$*" == "$needle"* ]]
}

# Test whether text ends with a suffix.
# Inputs:
#   $1 - Suffix string.
#   $* - Text to test after the suffix.
#
# Output:
#   None.
#
# Returns:
#   0 when the combined text ends with the suffix; 1 otherwise.
#
# Example:
#   str_ends_with ".sh" "$file"
function str_ends_with ()
{
    local needle=$1
    shift
    [[ "$*" == *"$needle" ]]
}

# Test that a string does not match a Bash pattern.
# Inputs:
#   $1 - String to test.
#   $2 - Bash pattern.
#
# Output:
#   None.
#
# Returns:
#   0 when the string does not match the pattern; 1 when it matches.
#
# Example:
#   str_is_match "$value" "*[!0-9]*"
function str_is_match ()
{
    # shellcheck disable=SC2053
    if [[ "$1" != $2 ]] ; then
        return 0
    else
        return 1
    fi
}

# Test whether a string contains only digits.
# Inputs:
#   $1 - String to test.
#
# Output:
#   None.
#
# Returns:
#   0 when all characters are digits; 1 otherwise.
#
# Example:
#   str_is_digit "$port"
function str_is_digit ()
{
    str_is_match "$1" "*[!0-9]*"
}

# Test whether a string contains only ASCII letters.
# Inputs:
#   $1 - String to test.
#
# Output:
#   None.
#
# Returns:
#   0 when all characters are letters A-Z or a-z; 1 otherwise.
#
# Example:
#   str_is_alpha "$name"
function str_is_alpha ()
{
    str_is_match "$1" "*[!a-zA-Z]*"
}

# Test whether a string contains only ASCII letters and digits.
# Inputs:
#   $1 - String to test.
#
# Output:
#   None.
#
# Returns:
#   0 when all characters are alphanumeric; 1 otherwise.
#
# Example:
#   str_is_alnum "$slug"
function str_is_alnum ()
{
    str_is_match "$1" "*[!0-9a-zA-Z]*"
}
