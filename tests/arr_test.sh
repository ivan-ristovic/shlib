#!/usr/bin/env bash
# shellcheck disable=SC2317
set -u

source "$(dirname "${BASH_SOURCE[0]}")/helper.bash"
source "$SHLIB_ROOT/arr.sh"

test_arr_append_print_and_size() {
    local -a values=()

    arr_append values "one" "two words" "three"

    assert_command_output "3" arr_size values
    assert_command_output $'one\ntwo words\nthree' arr_print values
}

test_arr_append_existing_array() {
    local -a values=("first")

    arr_append values "second" "third"

    assert_eq "3" "${#values[@]}"
    assert_eq "first" "${values[0]}"
    assert_eq "second" "${values[1]}"
    assert_eq "third" "${values[2]}"
}

test_arr_reverse_and_uniq() {
    assert_command_output $'three\ntwo\none' arr_reverse "one" "two" "three"

    local unique
    unique="$(arr_uniq "alpha" "beta" "alpha" "" "gamma" | sort)"
    assert_eq $'alpha\nbeta\ngamma' "$unique"
}

test_arr_rand_elem() {
    assert_command_output "only" arr_rand_elem "only"
}

run_test "array append, print, and size" test_arr_append_print_and_size
run_test "array append preserves existing elements" test_arr_append_existing_array
run_test "array reverse and unique values" test_arr_reverse_and_uniq
run_test "array random element with single value" test_arr_rand_elem

finish_tests
