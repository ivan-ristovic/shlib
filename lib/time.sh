#!/bin/bash

source "$SHLIB_ROOT/std.sh"

# Print the current Unix timestamp.
# Inputs:
#   None.
#
# Output:
#   Writes seconds since the Unix epoch to stdout.
#
# Returns:
#   0 unless date fails.
#
# Example:
#   started_at=$(time_now)
function time_now ()
{
    date +%s
}

# Print the current ISO date.
# Inputs:
#   None.
#
# Output:
#   Writes the current local date in ISO-8601 date form.
#
# Returns:
#   0 unless date fails.
#
# Example:
#   today=$(date_now)
function date_now ()
{
    date --iso
}

