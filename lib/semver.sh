#!/bin/bash

function _semver_parts ()
{
    local version="$1" major minor patch

    [[ "$version" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]] || return 1
    major="${BASH_REMATCH[1]}"
    minor="${BASH_REMATCH[2]}"
    patch="${BASH_REMATCH[3]}"

    printf '%s %s %s\n' "$((10#$major))" "$((10#$minor))" "$((10#$patch))"
}

# Parse a semantic version.
# Inputs:
#   $1 - Version in MAJOR.MINOR.PATCH form.
#
# Output:
#   Writes "MAJOR MINOR PATCH" with normalized integer components.
#
# Returns:
#   0 for a valid version; 1 for invalid input.
#
# Example:
#   read -r major minor patch < <(semver_parse 1.2.3)
function semver_parse ()
{
    _semver_parts "$1"
}

# Compare two semantic versions.
# Inputs:
#   $1 - Left version in MAJOR.MINOR.PATCH form.
#   $2 - Right version in MAJOR.MINOR.PATCH form.
#
# Output:
#   Writes -1, 0, or 1 when the left version is lower, equal, or greater.
#
# Returns:
#   0 on successful comparison; 1 when either version is invalid.
#
# Example:
#   case "$(semver_cmp "$current" 2.0.0)" in -1) upgrade ;; esac
function semver_cmp ()
{
    local a_major a_minor a_patch b_major b_minor b_patch

    read -r a_major a_minor a_patch < <(_semver_parts "$1") || return 1
    read -r b_major b_minor b_patch < <(_semver_parts "$2") || return 1

    if (( a_major < b_major )); then
        printf '%s\n' -1
    elif (( a_major > b_major )); then
        printf '%s\n' 1
    elif (( a_minor < b_minor )); then
        printf '%s\n' -1
    elif (( a_minor > b_minor )); then
        printf '%s\n' 1
    elif (( a_patch < b_patch )); then
        printf '%s\n' -1
    elif (( a_patch > b_patch )); then
        printf '%s\n' 1
    else
        printf '%s\n' 0
    fi
}

# Test whether two semantic versions are equal.
# Inputs:
#   $1 - Left version.
#   $2 - Right version.
#
# Output:
#   None.
#
# Returns:
#   0 when versions compare equal; 1 otherwise or when parsing fails.
#
# Example:
#   semver_eq 1.2.3 1.2.3
function semver_eq () { [[ "$(semver_cmp "$1" "$2")" == 0 ]]; }
# Test whether the left semantic version is lower than the right.
# Inputs:
#   $1 - Left version.
#   $2 - Right version.
#
# Output:
#   None.
#
# Returns:
#   0 when $1 is lower than $2; 1 otherwise or when parsing fails.
#
# Example:
#   if semver_lt "$installed" 2.0.0; then echo upgrade; fi
function semver_lt () { [[ "$(semver_cmp "$1" "$2")" == -1 ]]; }
# Test whether the left semantic version is lower than or equal to the right.
# Inputs:
#   $1 - Left version.
#   $2 - Right version.
#
# Output:
#   None.
#
# Returns:
#   0 when $1 is lower than or equal to $2; 1 otherwise or when parsing fails.
#
# Example:
#   semver_le "$required" "$available"
function semver_le () { local cmp; cmp="$(semver_cmp "$1" "$2")" || return 1; [[ "$cmp" == -1 || "$cmp" == 0 ]]; }
# Test whether the left semantic version is greater than the right.
# Inputs:
#   $1 - Left version.
#   $2 - Right version.
#
# Output:
#   None.
#
# Returns:
#   0 when $1 is greater than $2; 1 otherwise or when parsing fails.
#
# Example:
#   semver_gt "$latest" "$installed"
function semver_gt () { [[ "$(semver_cmp "$1" "$2")" == 1 ]]; }
# Test whether the left semantic version is greater than or equal to the right.
# Inputs:
#   $1 - Left version.
#   $2 - Right version.
#
# Output:
#   None.
#
# Returns:
#   0 when $1 is greater than or equal to $2; 1 otherwise or when parsing fails.
#
# Example:
#   semver_ge "$installed" 1.5.0
function semver_ge () { local cmp; cmp="$(semver_cmp "$1" "$2")" || return 1; [[ "$cmp" == 1 || "$cmp" == 0 ]]; }
