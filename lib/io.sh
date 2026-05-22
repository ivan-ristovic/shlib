#!/bin/bash

source "$SHLIB_ROOT/assert.sh"

# Test that every path is a directory.
# Inputs:
#   $@ - Paths to test.
#
# Output:
#   None.
#
# Returns:
#   0 when all paths are directories; 1 otherwise.
#
# Example:
#   io_is_dir "$HOME" /tmp
function io_is_dir ()
{
    test_all -d "$@"
}

# Test that every path is a block device.
# Inputs:
#   $@ - Paths to test.
#
# Output:
#   None.
#
# Returns:
#   0 when all paths are block devices; 1 otherwise.
#
# Example:
#   io_is_dev /dev/sda
function io_is_dev ()
{
    test_all -b "$@"
}

# Test that every path is a regular file.
# Inputs:
#   $@ - Paths to test.
#
# Output:
#   None.
#
# Returns:
#   0 when all paths are regular files; 1 otherwise.
#
# Example:
#   io_is_file README.md LICENSE
function io_is_file ()
{
    test_all -f "$@"
}

# Read one delimited record into a variable.
# Inputs:
#   --delim CHAR - Optional delimiter; defaults to newline.
#   --fd FD - Optional file descriptor; defaults to 0.
#   VAR - Name of the output variable.
#
# Output:
#   None; assigns the next record to VAR, including a final unterminated
#   record at EOF.
#
# Returns:
#   0 when a record is read; 1 at EOF with no buffered data.
#
# Example:
#   while io_readline line; do printf '[%s]\n' "$line"; done < input.txt
function io_readline()
{
    declare -n _var
    declare _arg=""
    declare -i _fd="0"
    declare _delim=$'\n'

    # parse param string
    while (($# > 0)); do
        case "$1" in
            --)
                shift
                break
                ;;
            --*)
                _arg="${1#--}"
                case "${_arg}" in
                    delim)
                        shift
                        _delim="$1"
                        ;;
                    fd)
                        shift
                        _fd="$1"
                        ;;
                    *)  ;;
                esac
                shift
                ;;
            *)
                _var="$1"
                break
                ;;
        esac
    done

    if ! IFS= read -d "${_delim}" -u "$_fd" -r _var; then
        [[ "${_var}" ]]
    fi
}

# Read all delimited records into an array.
# Inputs:
#   --delim CHAR - Optional delimiter; defaults to newline.
#   --fd FD - Optional file descriptor; defaults to 0.
#   ARRAY - Name of the output array.
#
# Output:
#   None; appends records to ARRAY, including a final unterminated record.
#
# Returns:
#   0 unless reading from the chosen file descriptor fails.
#
# Example:
#   io_readlines lines < input.txt
function io_readlines ()
{
    declare -n _arr
    declare _str="" _arg=""
    declare -i _fd="0"
    declare _delim=$'\n'

    # parse param string
    while (($# > 0)); do
        case "$1" in
            --)
                shift
                break
                ;;
            --*)
                _arg="${1#--}"
                case "${_arg}" in
                    delim)
                        shift
                        _delim="$1"
                        ;;
                    fd)
                        shift
                        _fd="$1"
                        ;;
                    *)  ;;
                esac
                shift
                ;;
            *)
                _arr="$1"
                break
                ;;
        esac
    done

    while io_readline --delim "${_delim}" --fd "$_fd" _str; do
        _arr+=("${_str}")
    done
}
