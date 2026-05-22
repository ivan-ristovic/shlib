#!/bin/bash

# Test whether a command is available in PATH.
# Inputs:
#   $1 - Command name to search for.
#
# Output:
#   None.
#
# Returns:
#   0 when the command exists; non-zero otherwise.
#
# Example:
#   if cmd_exists git; then git status; fi
function cmd_exists ()
{
    command -v "$1" >/dev/null 2>&1
}

# Require one or more commands to exist in PATH.
# Inputs:
#   $@ - Command names to check.
#
# Output:
#   Writes one "missing command" line to stderr for each missing command.
#
# Returns:
#   0 when all commands exist; 1 when any command is missing.
#
# Example:
#   cmd_require git curl || exit 1
function cmd_require ()
{
    local cmd missing=0

    for cmd in "$@"; do
        if ! cmd_exists "$cmd"; then
            printf 'missing command: %s\n' "$cmd" >&2
            missing=1
        fi
    done

    return "$missing"
}

# Run a command and store its stdout in a named variable.
# Inputs:
#   $1 - Output variable name.
#   $@ - Command and arguments after the variable name.
#
# Output:
#   None on stdout; assigns captured stdout to the named variable.
#
# Returns:
#   The command's exit status.
#
# Example:
#   cmd_capture branch git rev-parse --abbrev-ref HEAD
function cmd_capture ()
{
    local -n _cmd_capture_out="$1"
    local _cmd_capture_output _cmd_capture_status
    shift

    _cmd_capture_output="$("$@")"
    _cmd_capture_status=$?
    _cmd_capture_out="$_cmd_capture_output"
    return "$_cmd_capture_status"
}

# Retry a command until it succeeds or attempts are exhausted.
# Inputs:
#   $1 - Maximum attempts.
#   $2 - Delay in seconds between attempts.
#   $@ - Command and arguments after the delay.
#
# Output:
#   The wrapped command may write to stdout or stderr.
#
# Returns:
#   0 when any attempt succeeds; otherwise the last command status.
#
# Example:
#   cmd_retry 5 1 curl -fsS https://example.com/health
function cmd_retry ()
{
    local max_attempts="$1" delay="$2" try status=1
    shift 2

    if (( max_attempts < 1 )); then
        return 1
    fi

    for ((try = 1; try <= max_attempts; try++)); do
        "$@" && return 0
        status=$?
        if (( try < max_attempts )); then
            sleep "$delay"
        fi
    done

    return "$status"
}

# Run a command through the external timeout command.
# Inputs:
#   $1 - Timeout duration accepted by timeout, such as "5" or "2s".
#   $@ - Command and arguments after the duration.
#
# Output:
#   The wrapped command may write to stdout or stderr; missing timeout is
#   reported to stderr.
#
# Returns:
#   The timeout command status; 127 when timeout is not installed.
#
# Example:
#   cmd_timeout 10s long_running_job
function cmd_timeout ()
{
    local seconds="$1"
    shift

    if ! cmd_exists timeout; then
        printf 'missing command: timeout\n' >&2
        return 127
    fi

    timeout "$seconds" "$@"
}
