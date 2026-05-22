#!/bin/bash

source "$SHLIB_ROOT/std.sh"

# Require an exact argument count.
# Inputs:
#   $1 - Actual argument count.
#   $2 - Expected argument count.
#   $* - Optional usage message after the expected count.
#
# Output:
#   Writes usage text through std_usage when the count differs.
#
# Returns:
#   0 when counts match; otherwise exits through std_usage.
#
# Example:
#   assert_argc "$#" 2 "SRC DEST"
function assert_argc ()
{
    local actual=$1
    local expected=$2
    shift 2
    if [ "$expected" -ne "$actual" ]; then
        if [ $# -gt 0 ]; then
            std_usage "$*"
        else
            std_usage "expected $expected arguments, got $actual"
        fi
    fi
}

# Require a minimum argument count.
# Inputs:
#   $1 - Actual argument count.
#   $2 - Minimum expected count.
#   $* - Optional usage message after the expected count.
#
# Output:
#   Writes usage text through std_usage when too few arguments are present.
#
# Returns:
#   0 when the count is high enough; otherwise exits through std_usage.
#
# Example:
#   assert_argc_ge "$#" 1 "FILE..."
function assert_argc_ge ()
{
    local actual=$1
    local expected=$2
    shift 2
    if [ "$actual" -lt "$expected" ]; then
        if [ $# -gt 0 ]; then
            std_usage "$*"
        else
            std_usage "expected $expected arguments, got $actual"
        fi
    fi
}

# Require at least one argument.
# Inputs:
#   $1 - Argument count.
#   $* - Usage message after the count.
#
# Output:
#   Writes usage text through std_usage when the count is zero.
#
# Returns:
#   0 when the count is non-zero; otherwise exits through std_usage.
#
# Example:
#   assert_args "$#" "COMMAND [ARG...]"
function assert_args ()
{
    if [ "$1" -eq 0 ]; then
        shift
        std_usage "$*"
    fi
}

# Require the current directory name to match one of the allowed names.
# Inputs:
#   $@ - Allowed directory basenames.
#
# Output:
#   Writes a fatal assertion message when PWD does not match.
#
# Returns:
#   0 on match; otherwise exits through assert_that.
#
# Example:
#   assert_pwd shlib project-root
function assert_pwd ()
{
    local found=false
    local dir
    for dir in "$@" ; do
        if [ "${PWD##*/}" == "$dir" ] ; then
            found=true
        fi
    done

    assert_that "current dir must be any of: $*" "$found"
}

# Test whether a shell variable is defined.
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
#   test_var_defined HOME
function test_var_defined ()
{
    [[ "${!1-X}" == "${!1-Y}" ]]
}

# Assert that a shell variable is defined.
# Inputs:
#   $1 - Variable name.
#
# Output:
#   Writes a fatal assertion message when the variable is undefined.
#
# Returns:
#   0 when defined; otherwise exits through assert_that.
#
# Example:
#   assert_var_defined HOME
function assert_var_defined ()
{
    assert_that "expect var defined: $1" test_var_defined "$1"
}

# Test whether a shell variable is defined and non-empty.
# Inputs:
#   $1 - Variable name.
#
# Output:
#   None.
#
# Returns:
#   0 when the variable is defined and non-empty; 1 otherwise.
#
# Example:
#   test_var_set API_TOKEN
function test_var_set ()
{
    test_var_defined "$1" && [[ -n ${!1} ]]
}

# Assert that a shell variable is defined and non-empty.
# Inputs:
#   $1 - Variable name.
#
# Output:
#   Writes a fatal assertion message when the variable is unset or empty.
#
# Returns:
#   0 when set; otherwise exits through assert_that.
#
# Example:
#   assert_var_set API_TOKEN
function assert_var_set ()
{
    assert_that "expect var set: $1" test_var_set "$1"
}

# Test whether a shell function is defined.
# Inputs:
#   $1 - Function name.
#
# Output:
#   None.
#
# Returns:
#   0 when the function exists; 1 otherwise.
#
# Example:
#   test_fn_defined cleanup
function test_fn_defined ()
{
    declare -f "$1" >/dev/null
}

# Assert that a shell function is defined.
# Inputs:
#   $1 - Function name.
#
# Output:
#   Writes a fatal assertion message when the function is missing.
#
# Returns:
#   0 when defined; otherwise exits through assert_that.
#
# Example:
#   assert_fn_defined main
function assert_fn_defined ()
{
    assert_that "expext function defined: $1" test_fn_defined "$1"
}

# Run a test command against every argument.
# Inputs:
#   $1 - Test command or operator accepted by test.
#   $@ - Values to test after the command.
#
# Output:
#   None.
#
# Returns:
#   0 when every value passes; 1 when any value fails.
#
# Example:
#   test_all -f file1 file2
function test_all ()
{
    local args="$1"
    shift 1
    for f in "$@"; do
        if ! test "$args" "$f"; then
            return 1
        fi
    done
}

# Run a test command until any argument passes.
# Inputs:
#   $1 - Test command or operator accepted by test.
#   $@ - Values to test after the command.
#
# Output:
#   None.
#
# Returns:
#   0 when any value passes; 1 when all values fail.
#
# Example:
#   test_any -d "$HOME" /tmp
function test_any ()
{
    local args="$1"
    shift 1
    for f in "$@"; do
        if test "$args" "$f"; then
            return 0
        fi
    done
    return 1
}

# Assert that a command succeeds.
# Inputs:
#   $@ - Command and arguments to run.
#
# Output:
#   Writes a fatal assertion message when the command fails.
#
# Returns:
#   0 when the command succeeds; otherwise exits through std_fat.
#
# Example:
#   assert_pass git rev-parse --is-inside-work-tree
function assert_pass ()
{
    if ! "$@" ; then
        std_fat "assertion failed: $*"
    fi
}

# Assert that a command succeeds with a custom message.
# Inputs:
#   $1 - Failure message.
#   $@ - Command and arguments after the message.
#
# Output:
#   Writes the failure message through std_fat when the command fails.
#
# Returns:
#   0 when the command succeeds; otherwise exits through std_fat.
#
# Example:
#   assert_that "config must exist" test -f config.yml
function assert_that ()
{
    local msg="$1"
    shift 1
    if ! "$@" ; then
        std_fat "assertion failed: $msg"
    fi
}

# Test whether a command is installed.
# Inputs:
#   $@ - Command name and optional command arguments for command -v.
#
# Output:
#   None.
#
# Returns:
#   0 when command -v finds the command; 1 otherwise.
#
# Example:
#   test_installed shellcheck
function test_installed ()
{
    if command -v "$@" &> /dev/null ; then
        return 0
    else
        return 1
    fi
}

# Assert that a command is installed.
# Inputs:
#   $@ - Command name to check.
#
# Output:
#   Writes a fatal assertion message when the command is missing.
#
# Returns:
#   0 when installed; otherwise exits through assert_that.
#
# Example:
#   assert_installed shellcheck
function assert_installed ()
{
    assert_that "expect installed: $*" test_installed "$@"
}
