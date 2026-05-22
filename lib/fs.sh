#!/bin/bash

# Test whether a path exists.
# Inputs:
#   $1 - Path to test.
#
# Output:
#   None.
#
# Returns:
#   0 when the path exists; 1 otherwise.
#
# Example:
#   fs_exists config.yml || printf 'missing config\n' >&2
function fs_exists ()
{
    [[ -e "$1" ]]
}

# Test whether a file or directory is empty.
# Inputs:
#   $1 - File or directory path.
#
# Output:
#   None.
#
# Returns:
#   0 for empty files or directories; 1 for non-empty or missing paths.
#
# Example:
#   if fs_is_empty "$cache_dir"; then rebuild_cache; fi
function fs_is_empty ()
{
    local path="$1"

    if [[ -d "$path" ]]; then
        [[ -z "$(find "$path" -mindepth 1 -maxdepth 1 -print -quit)" ]]
    elif [[ -e "$path" ]]; then
        [[ ! -s "$path" ]]
    else
        return 1
    fi
}

# Create directories with mkdir -p.
# Inputs:
#   $@ - Directory paths to create.
#
# Output:
#   mkdir may write diagnostics to stderr.
#
# Returns:
#   0 when all directories exist or are created; non-zero from mkdir on failure.
#
# Example:
#   fs_mkdirp "$HOME/.cache/my-tool"
function fs_mkdirp ()
{
    mkdir -p -- "$@"
}

# Create a temporary directory and print its path.
# Inputs:
#   $1 - Optional filename prefix; defaults to "shlib".
#
# Output:
#   Writes the created directory path to stdout.
#
# Returns:
#   0 on success; non-zero from mktemp on failure.
#
# Example:
#   tmpdir=$(fs_tempdir my-tool)
function fs_tempdir ()
{
    local prefix="${1:-shlib}"
    mktemp -d "${TMPDIR:-/tmp}/${prefix}.XXXXXX"
}

# Print a canonical path.
# Inputs:
#   $1 - Path to resolve.
#
# Output:
#   Writes the resolved path to stdout.
#
# Returns:
#   0 on success; non-zero when neither realpath nor readlink can resolve it.
#
# Example:
#   target=$(fs_readlink "$symlink")
function fs_readlink ()
{
    if command -v realpath >/dev/null 2>&1; then
        realpath -- "$1"
    else
        readlink -f -- "$1"
    fi
}

# Print the final path component.
# Inputs:
#   $1 - Path.
#
# Output:
#   Writes the basename to stdout.
#
# Returns:
#   0 unless basename fails.
#
# Example:
#   name=$(fs_basename /tmp/report.txt)
function fs_basename ()
{
    basename -- "$1"
}

# Print the parent path component.
# Inputs:
#   $1 - Path.
#
# Output:
#   Writes the dirname to stdout.
#
# Returns:
#   0 unless dirname fails.
#
# Example:
#   parent=$(fs_dirname /tmp/report.txt)
function fs_dirname ()
{
    dirname -- "$1"
}

# Remove an empty directory.
# Inputs:
#   $1 - Directory path to remove.
#
# Output:
#   rmdir may write diagnostics to stderr.
#
# Returns:
#   0 when the directory is removed; non-zero when it is missing or non-empty.
#
# Example:
#   fs_rm_empty_dir "$tmpdir"
function fs_rm_empty_dir ()
{
    rmdir -- "$1"
}
