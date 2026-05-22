#!/bin/bash

source "$SHLIB_ROOT/log.sh"

# Print a usage error and exit.
# Inputs:
#   $* - Usage message text.
#
# Output:
#   Writes a fatal usage log line to stdout.
#
# Returns:
#   Does not return; exits with status 1.
#
# Example:
#   [[ $# -gt 0 ]] || std_usage "FILE"
function std_usage ()
{
    std_fat "usage: $(basename "$0") $*"
}

# Print a fatal error and exit.
# Inputs:
#   $* - Error message text.
#
# Output:
#   Writes a fatal log line to stdout.
#
# Returns:
#   Does not return; exits with status 1.
#
# Example:
#   [[ -r "$file" ]] || std_fat "cannot read $file"
function std_fat ()
{
    log_log "FAT" "$SHLIB_FMT_C_R" "$*"
    exit 1
}

# Ask an interactive yes/no question.
# Inputs:
#   $1 - Question text.
#   $2 - Optional default marker: "Y", "N", or empty for no default.
#
# Output:
#   Writes the prompt to stdout and reads from SHLIB_TTY or /dev/tty.
#
# Returns:
#   0 for yes; 1 for no.
#
# Example:
#   if std_ask "Continue?" Y; then run_step; fi
function std_ask ()
{
    local default prompt

    while true; do

        if [ "${2:-}" = "Y" ]; then
            prompt="Y/n"
            default=Y
        elif [ "${2:-}" = "N" ]; then
            prompt="y/N"
            default=N
        else
            prompt="y/n"
            default=
        fi

        # Ask the question (not using "read -p" as it uses stderr not stdout)
        printf '%s [%s] ' "$1" "$prompt"

        # Read the answer (use /dev/tty in case stdin is redirected from somewhere else)
        read -r REPLY <"${SHLIB_TTY:-/dev/tty}"
        sleep "${SHLIB_ASK_DELAY:-1}"

        # Default?
        if [ -z "$REPLY" ]; then
            REPLY="$default"
        fi

        # Check if the reply is valid
        case "$REPLY" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac

    done
}

# Run a command and wait for one key press.
# Inputs:
#   $@ - Command and arguments to execute.
#
# Output:
#   The command may write output; the prompt is written by read.
#
# Returns:
#   0 unless the command or read fails.
#
# Example:
#   std_confirm less README.md
function std_confirm ()
{
    "$@"
    read -n 1 -s -r -p "Press any key to continue"
    printf '\r'
}

function _std_beep_v ()
{
    local beep_pid

    speaker-test -Dpulse -f "$1" --test sine -l 1 &
    beep_pid=$!
    sleep "$2"
    kill -9 "$beep_pid"
}

# Play a short PulseAudio sine tone.
# Inputs:
#   $1 - Optional frequency; defaults to 1500.
#   $2 - Optional duration in seconds; defaults to .1.
#
# Output:
#   None; helper output is discarded.
#
# Returns:
#   0 when the helper command sequence succeeds; non-zero otherwise.
#
# Example:
#   std_beep 880 .2
function std_beep ()
{
    local freq="${1:-1500}"
    local duration="${2:-.1}"

    _std_beep_v "$freq" "$duration" > /dev/null 2>&1
}
