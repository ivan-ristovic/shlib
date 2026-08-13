#!/usr/bin/env bash
# shellcheck disable=SC2317
set -u

source "$(dirname "${BASH_SOURCE[0]}")/helper.bash"
source "$SHLIB_ROOT/fs.sh"

test_fs_predicates_and_dirs() {
    local tmpdir file empty_dir nonempty_dir
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' RETURN

    file="$tmpdir/file"
    empty_dir="$tmpdir/empty"
    nonempty_dir="$tmpdir/nonempty"

    fs_mkdirp "$empty_dir" "$nonempty_dir"
    : > "$file"
    printf 'x' > "$nonempty_dir/value"

    assert_success fs_exists "$file"
    assert_failure fs_exists "$tmpdir/missing"
    assert_success fs_is_empty "$file"
    assert_success fs_is_empty "$empty_dir"
    assert_failure fs_is_empty "$nonempty_dir"
}

test_fs_paths_and_tempdir() {
    local tmpdir nested temp
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' RETURN

    nested="$tmpdir/a/b"
    fs_mkdirp "$nested"
    ln -s "$nested" "$tmpdir/link"

    assert_command_output "file.txt" fs_basename "$nested/file.txt"
    assert_command_output "$nested" fs_dirname "$nested/file.txt"
    assert_command_output "$(realpath "$nested")" fs_readlink "$tmpdir/link"

    TMPDIR="$tmpdir" temp="$(fs_tempdir shlib-test)"
    assert_success fs_exists "$temp"
    assert_success fs_rm_empty_dir "$temp"
    assert_failure fs_exists "$temp"
}

run_test "filesystem predicates and directory creation" test_fs_predicates_and_dirs
run_test "filesystem path helpers and tempdir" test_fs_paths_and_tempdir

finish_tests
