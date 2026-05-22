#!/usr/bin/env bash
set -u

source "$(dirname "${BASH_SOURCE[0]}")/helper.bash"
source "$SHLIB_ROOT/cmd.sh"

test_cmd_exists_and_require() {
    assert_success cmd_exists bash
    assert_failure cmd_exists "shlib_missing_command_$$"
    assert_success cmd_require bash

    capture_subshell cmd_require "shlib_missing_command_$$"
    assert_eq "1" "$SHLIB_CAPTURE_STATUS"
    assert_contains "$SHLIB_CAPTURE_OUTPUT" "missing command: shlib_missing_command_$$"
}

test_cmd_capture() {
    local output

    cmd_capture output printf 'hello'
    assert_eq "hello" "$output"

    set +e
    cmd_capture output bash -c 'printf fail; exit 7'
    local status=$?
    set -e
    assert_eq "7" "$status"
    assert_eq "fail" "$output"
}

test_cmd_retry() {
    local attempts=0

    # shellcheck disable=SC2329
    _cmd_retry_eventual_success() {
        attempts=$((attempts + 1))
        (( attempts >= 3 ))
    }

    cmd_retry 4 0 _cmd_retry_eventual_success
    assert_eq "3" "$attempts"

    attempts=0
    set +e
    cmd_retry 2 0 false
    local status=$?
    set -e
    assert_eq "1" "$status"
}

test_cmd_timeout() {
    # shellcheck disable=SC2329
    timeout() {
        local seconds="$1"
        shift
        printf 'timeout:%s:' "$seconds"
        "$@"
    }

    assert_command_output "timeout:5:ok" cmd_timeout 5 printf ok

    (
        # shellcheck disable=SC2329
        cmd_exists() { return 1; }
        capture_subshell cmd_timeout 1 true
        assert_eq "127" "$SHLIB_CAPTURE_STATUS"
        assert_contains "$SHLIB_CAPTURE_OUTPUT" "missing command: timeout"
    )
}

run_test "command existence and requirements" test_cmd_exists_and_require
run_test "command output capture" test_cmd_capture
run_test "command retry" test_cmd_retry
run_test "command timeout" test_cmd_timeout

finish_tests
