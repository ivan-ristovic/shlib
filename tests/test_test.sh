#!/usr/bin/env bash
set -u

source "$(dirname "${BASH_SOURCE[0]}")/helper.bash"
source "$SHLIB_ROOT/test.sh"

test_test_assertions() {
    test_assert_eq "a" "a"
    test_assert_ne "a" "b"
    test_assert_contains "abc" "b"
    test_assert_match "abc123" '^[a-z]+[0-9]+$'
    test_assert_success true
    test_assert_failure false
    test_assert_command_output "ok" printf ok

    capture_subshell test_assert_eq "a" "b"
    assert_eq "1" "$SHLIB_CAPTURE_STATUS"
    assert_contains "$SHLIB_CAPTURE_OUTPUT" "expected"
}

test_test_subshell_status() {
    test_assert_subshell_status 7 'exit 7'
}

run_test "reusable test assertions" test_test_assertions
run_test "reusable subprocess status assertion" test_test_subshell_status

finish_tests
