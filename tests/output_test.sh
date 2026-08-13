#!/usr/bin/env bash
# shellcheck disable=SC2317
set -u

source "$(dirname "${BASH_SOURCE[0]}")/helper.bash"
source "$SHLIB_ROOT/output.sh"

test_output_kv_and_list() {
    assert_command_output "name=ivan" output_kv name ivan
    assert_command_output $'one\ntwo\nthree' output_list one two three
}

test_output_table() {
    local -a headers=("Name" "Age")
    # shellcheck disable=SC2034
    local -a rows=($'Ivan\t42' $'Ana\t7')

    assert_command_output $'Name  Age\n----  ---\nIvan  42 \nAna   7  ' output_table headers rows

    # shellcheck disable=SC2034
    headers=()
    capture_subshell output_table headers rows
    assert_eq "2" "$SHLIB_CAPTURE_STATUS"
    assert_contains "$SHLIB_CAPTURE_OUTPUT" "requires at least one header"
}

run_test "key/value and list output" test_output_kv_and_list
run_test "table output" test_output_table

finish_tests
