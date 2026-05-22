#!/usr/bin/env bash
set -u

source "$(dirname "${BASH_SOURCE[0]}")/helper.bash"
source "$SHLIB_ROOT/assert.sh"

test_assert_arg_counts() {
    assert_argc 2 2
    assert_argc_ge 3 2
    assert_args 1 "need args"

    capture_subshell assert_argc 1 2 "need two"
    assert_eq "1" "$SHLIB_CAPTURE_STATUS"
    assert_contains "$SHLIB_CAPTURE_OUTPUT" "usage:"
    assert_contains "$SHLIB_CAPTURE_OUTPUT" "need two"

    capture_subshell assert_argc_ge 1 2 "need at least two"
    assert_eq "1" "$SHLIB_CAPTURE_STATUS"
    assert_contains "$SHLIB_CAPTURE_OUTPUT" "need at least two"

    capture_subshell assert_args 0 "need args"
    assert_eq "1" "$SHLIB_CAPTURE_STATUS"
    assert_contains "$SHLIB_CAPTURE_OUTPUT" "need args"
}

test_assert_pwd() {
    assert_pwd "shlib"

    capture_subshell assert_pwd "not-shlib"
    assert_eq "1" "$SHLIB_CAPTURE_STATUS"
    assert_contains "$SHLIB_CAPTURE_OUTPUT" "current dir must be any of: not-shlib"
}

test_assert_variables_and_functions() {
    # shellcheck disable=SC2034
    local value="set" empty=""
    unset missing_value || :

    assert_success test_var_defined value
    assert_success test_var_defined empty
    assert_failure test_var_defined missing_value
    assert_var_defined value

    assert_success test_var_set value
    assert_failure test_var_set empty
    assert_failure test_var_set missing_value
    assert_var_set value

    assert_success test_fn_defined assert_pass
    assert_failure test_fn_defined no_such_shlib_function
    assert_fn_defined assert_pass

    capture_subshell assert_var_defined missing_value
    assert_eq "1" "$SHLIB_CAPTURE_STATUS"
    capture_subshell assert_var_set empty
    assert_eq "1" "$SHLIB_CAPTURE_STATUS"
    capture_subshell assert_fn_defined no_such_shlib_function
    assert_eq "1" "$SHLIB_CAPTURE_STATUS"
}

test_assert_test_all_any() {
    local tmpdir file
    tmpdir="$(mktemp -d)"
    file="$tmpdir/file"
    printf 'x' > "$file"
    trap 'rm -rf "$tmpdir"' RETURN

    assert_success test_all -f "$file"
    assert_failure test_all -f "$file" "$tmpdir"
    assert_success test_any -d "$file" "$tmpdir"
    assert_failure test_any -b "$file" "$tmpdir"
}

test_assert_commands_and_installed() {
    assert_pass true
    assert_that "true passes" true
    assert_success test_installed bash
    assert_installed bash

    capture_subshell assert_pass false
    assert_eq "1" "$SHLIB_CAPTURE_STATUS"
    assert_contains "$SHLIB_CAPTURE_OUTPUT" "assertion failed: false"

    capture_subshell assert_that "custom failure" false
    assert_eq "1" "$SHLIB_CAPTURE_STATUS"
    assert_contains "$SHLIB_CAPTURE_OUTPUT" "custom failure"

    assert_failure test_installed "shlib_missing_command_$$"
    capture_subshell assert_installed "shlib_missing_command_$$"
    assert_eq "1" "$SHLIB_CAPTURE_STATUS"
}

run_test "argument count assertions" test_assert_arg_counts
run_test "current directory assertion" test_assert_pwd
run_test "variable and function assertions" test_assert_variables_and_functions
run_test "test_all and test_any" test_assert_test_all_any
run_test "command assertions and installed checks" test_assert_commands_and_installed

finish_tests
