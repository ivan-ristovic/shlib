#!/usr/bin/env bash
# shellcheck disable=SC2317

SHLIB_TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHLIB_REPO_ROOT="$(cd "$SHLIB_TEST_DIR/.." && pwd)"
export SHLIB_ROOT="$SHLIB_REPO_ROOT/lib"

source "$SHLIB_ROOT/test.sh"

assert_eq() { test_assert_eq "$@"; }
assert_ne() { test_assert_ne "$@"; }
assert_contains() { test_assert_contains "$@"; }
assert_match() { test_assert_match "$@"; }
assert_status() { test_assert_status "$@"; }
assert_success() { test_assert_success "$@"; }
assert_failure() { test_assert_failure "$@"; }
assert_command_output() { test_assert_command_output "$@"; }
capture_subshell() { test_capture_subshell "$@"; }
assert_subshell_status() { test_assert_subshell_status "$@"; }
run_test() { test_run "$@"; }
finish_tests() { test_finish; }
