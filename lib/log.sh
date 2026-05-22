#!/bin/bash

SHLIB_LOG_DEBUG=false
SHLIB_FMT_PROMPT=": "
SHLIB_FMT_C_R='\033[0;31m'
SHLIB_FMT_C_G='\033[0;32m'
SHLIB_FMT_C_Y='\033[0;33m'
SHLIB_FMT_C_B='\033[0;34m'
SHLIB_FMT_C_M='\033[0;34m'
SHLIB_FMT_S_B='\033[1m'
SHLIB_FMT_CLR='\033[0m'

# Log a command line, then execute it.
# Inputs:
#   $@ - Command and arguments to run.
#
# Output:
#   Writes the log line and the command's stdout or stderr.
#
# Returns:
#   The wrapped command's exit status.
#
# Example:
#   log_exec git pull --ff-only
function log_exec ()
{
    log_msg "executing: $*"
    "$@"
}

# Print a debug log message when SHLIB_LOG_DEBUG is true.
# Inputs:
#   $* - Message text.
#
# Output:
#   Writes a colored debug line to stdout when enabled.
#
# Returns:
#   0.
#
# Example:
#   SHLIB_LOG_DEBUG=true; log_dbg "loading config"
function log_dbg ()
{
    if $SHLIB_LOG_DEBUG ; then
        log_log "dbg" "$SHLIB_FMT_C_M" "$*"
    fi
}

# Print a success log message.
# Inputs:
#   $* - Message text.
#
# Output:
#   Writes a colored success line to stdout.
#
# Returns:
#   0 unless printf fails.
#
# Example:
#   log_suc "deploy complete"
function log_suc ()
{
    log_log "suc" "$SHLIB_FMT_C_G" "$*"
}

# Print an informational log message.
# Inputs:
#   $* - Message text.
#
# Output:
#   Writes a colored info line to stdout.
#
# Returns:
#   0 unless printf fails.
#
# Example:
#   log_msg "starting build"
function log_msg ()
{
    log_log "inf" "$SHLIB_FMT_C_B" "$*"
}

# Print a warning log message.
# Inputs:
#   $* - Message text.
#
# Output:
#   Writes a colored warning line to stdout.
#
# Returns:
#   0 unless printf fails.
#
# Example:
#   log_wrn "using fallback config"
function log_wrn ()
{
    log_log "WRN" "$SHLIB_FMT_C_Y" "$*"
}

# Print an error log message.
# Inputs:
#   $* - Message text.
#
# Output:
#   Writes a colored error line to stdout.
#
# Returns:
#   0 unless printf fails.
#
# Example:
#   log_err "request failed"
function log_err ()
{
    log_log "ERR" "$SHLIB_FMT_C_R" "$*"
}

# Print a log line with an explicit level and color.
# Inputs:
#   $1 - Level label.
#   $2 - ANSI color escape sequence.
#   $* - Message text after the color argument.
#
# Output:
#   Writes a formatted log line to stdout. Includes a timestamp when
#   SHLIB_FMT_TIME is set.
#
# Returns:
#   0 unless printf fails.
#
# Example:
#   log_log "DBG" "$SHLIB_FMT_C_B" "cache hit"
function log_log ()
{
    local level="$1"
    local color="$2"
    shift 2

    if [ -z "${SHLIB_FMT_TIME:-}" ]; then
        printf '%b[%s]%s%b%s\n' "$color" "$level" "$SHLIB_FMT_PROMPT" "$SHLIB_FMT_CLR" "$*"
    else
        printf '%b[%s]%b[%s]%s%b' "$SHLIB_FMT_S_B" "$(date +%T)" "$color" "$level" "$SHLIB_FMT_PROMPT" "$SHLIB_FMT_CLR"
        printf '%b\n' "$*"
    fi
}

# Print the current Bash call stack.
# Inputs:
#   None.
#
# Output:
#   Writes one stack frame per line to stdout.
#
# Returns:
#   0 unless printf fails.
#
# Example:
#   trap 'log_stacktrace' ERR
function log_stacktrace ()
{
    local frame=0 line func source n=0
    while caller "$frame"; do
        ((frame++))
    done | while read -r line func source; do
        ((n++ == 0)) && {
            log_log "trace" "red_i"
        }
        printf '%4s at %s\n' " " "$func ($source:$line)"
    done
}
