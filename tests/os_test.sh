#!/usr/bin/env bash
# shellcheck disable=SC2317
set -u

source "$(dirname "${BASH_SOURCE[0]}")/helper.bash"
source "$SHLIB_ROOT/os.sh"

test_os_path_normalization() {
    assert_command_output "/foo/bar/./w" os_path "/foo//bar/./w"
    assert_command_output "/" os_path "///"
    assert_command_output "." os_path "relative"
}

test_os_path_components() {
    assert_command_output "file.tar.gz" os_path_file "/tmp/file.tar.gz"
    assert_command_output "file.tar" os_path_file_noext "/tmp/file.tar.gz"
    assert_command_output "gz" os_path_ext "/tmp/file.tar.gz"
    assert_command_output "tar.gz" os_path_ext_full "/tmp/file.tar.gz"
    assert_command_output "/tmp/example" os_path_par "/tmp/example/file.txt"
}

test_os_path_abs() {
    local expected
    expected="$(realpath README.md)"
    assert_command_output "$expected" os_path_abs "README.md"
}

run_test "path normalization" test_os_path_normalization
run_test "path components" test_os_path_components
run_test "absolute path" test_os_path_abs

finish_tests
