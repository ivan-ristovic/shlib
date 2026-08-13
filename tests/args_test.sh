#!/usr/bin/env bash
# shellcheck disable=SC2317
set -u

source "$(dirname "${BASH_SOURCE[0]}")/helper.bash"
source "$SHLIB_ROOT/args.sh"

test_args_parse_long_forms() {
    local -a spec=() positionals=()
    local -A opts=()

    args_spec_add spec verbose flag v verbose false "Enable verbose output"
    args_spec_add spec name string n name guest "Set the name"
    args_spec_add spec count int c count 1 "Set the count"
    args_spec_add spec color string "" color blue "Set the color"
    args_spec_add spec dry_run flag "" dry-run true "Avoid writes"

    args_parse spec opts positionals --verbose --name=ivan --count 3 --color green input -- --literal

    assert_eq "true" "${opts[verbose]}"
    assert_eq "ivan" "${opts[name]}"
    assert_eq "3" "${opts[count]}"
    assert_eq "green" "${opts[color]}"
    assert_eq "true" "${opts[dry_run]}"
    assert_eq $'input\n--literal' "$(printf '%s\n' "${positionals[@]}")"

    args_parse spec opts positionals --no-dry-run
    assert_eq "false" "${opts[dry_run]}"
}

test_args_parse_short_forms_and_errors() {
    local -a spec=() positionals=()
    local -A opts=()

    args_spec_add spec verbose flag v verbose false "Enable verbose output"
    args_spec_add spec name string n name "" "Set the name"
    args_spec_add spec count int c count 0 "Set the count"

    args_parse spec opts positionals -v -n ana -c -2 file

    assert_eq "true" "${opts[verbose]}"
    assert_eq "ana" "${opts[name]}"
    assert_eq "-2" "${opts[count]}"
    assert_eq "file" "${positionals[0]}"

    capture_subshell args_parse spec opts positionals --missing
    assert_eq "2" "$SHLIB_CAPTURE_STATUS"
    assert_contains "$SHLIB_CAPTURE_OUTPUT" "unknown option: --missing"

    capture_subshell args_parse spec opts positionals --count nope
    assert_eq "2" "$SHLIB_CAPTURE_STATUS"
    assert_contains "$SHLIB_CAPTURE_OUTPUT" "expected int"

    capture_subshell args_parse spec opts positionals -vn
    assert_eq "2" "$SHLIB_CAPTURE_STATUS"
    assert_contains "$SHLIB_CAPTURE_OUTPUT" "short option clusters are not supported"
}

test_args_usage_and_spec_validation() {
    # shellcheck disable=SC2034
    local -a spec=()
    local output

    args_spec_add spec verbose flag v verbose false "Enable verbose output"
    args_spec_add spec count int c count 1 "Set the count"

    output="$(args_usage spec tool "Run the tool.")"
    assert_contains "$output" "Usage: tool [OPTIONS] [ARGS...]"
    assert_contains "$output" "Run the tool."
    assert_contains "$output" "-v, --verbose"
    assert_contains "$output" "--count VALUE"
    assert_contains "$output" "(default: 1)"

    capture_subshell args_spec_add spec verbose flag q quiet false "Duplicate"
    assert_eq "2" "$SHLIB_CAPTURE_STATUS"
    assert_contains "$SHLIB_CAPTURE_OUTPUT" "duplicate option"

    capture_subshell args_spec_add spec bad bool "" bad "" "Invalid"
    assert_eq "2" "$SHLIB_CAPTURE_STATUS"
    assert_contains "$SHLIB_CAPTURE_OUTPUT" "invalid option type"
}

run_test "argument parser long forms" test_args_parse_long_forms
run_test "argument parser short forms and errors" test_args_parse_short_forms_and_errors
run_test "argument parser usage and spec validation" test_args_usage_and_spec_validation

finish_tests
