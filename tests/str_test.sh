#!/usr/bin/env bash
set -u

source "$(dirname "${BASH_SOURCE[0]}")/helper.bash"
source "$SHLIB_ROOT/str.sh"

test_str_len_and_format() {
    local formatted=

    assert_command_output "3" str_len "abc"
    assert_command_output "0" str_len ""
    assert_command_output "item: abc" str_format "item: %s" "abc"

    str_format "[%s]" "abc" formatted
    assert_eq "[abc]" "$formatted"
}

test_str_join_replace_and_trim() {
    assert_command_output "a,b,c" str_join "," "a" "b" "c"
    assert_command_output "axcaxc" str_replace "abcabc" "b" "x"
    assert_command_output "hello" str_trim $' \t hello \n'
}

test_str_strip_variants() {
    assert_command_output "bnn" str_strip_a "a" "banana"
    assert_command_output "bnana" str_strip_f "a" "banana"
    assert_command_output "fix" str_strip_l "pre" "prefix"
    assert_command_output "pre" str_strip_r "fix" "prefix"
}

test_str_split_and_url_codec() {
    assert_command_output $'a\nb\nc' str_split "::" "a::b::c"
    assert_command_output "a%20b%2Bc%3F" str_url_encode "a b+c?"
    assert_command_output "a b c?" str_url_decode "a%20b+c%3F"
}

test_str_case_and_predicates() {
    assert_command_output "abc" str_to_lower "AbC"
    assert_command_output "ABC" str_to_upper "AbC"

    assert_success str_contains "bc" "abc"
    assert_failure str_contains "xy" "abc"
    assert_success str_starts_with "ab" "abc"
    assert_failure str_starts_with "bc" "abc"
    assert_success str_ends_with "bc" "abc"
    assert_failure str_ends_with "ab" "abc"

    assert_success str_is_match "abc" "*[!a-z]*"
    assert_failure str_is_match "abc1" "*[!a-z]*"
    assert_success str_is_digit "123"
    assert_failure str_is_digit "12a"
    assert_success str_is_alpha "abcXYZ"
    assert_failure str_is_alpha "abc1"
    assert_success str_is_alnum "abc123"
    assert_failure str_is_alnum "abc-123"
}

run_test "string length and formatting" test_str_len_and_format
run_test "string join, replace, and trim" test_str_join_replace_and_trim
run_test "string strip variants" test_str_strip_variants
run_test "string split and URL codec" test_str_split_and_url_codec
run_test "string case conversion and predicates" test_str_case_and_predicates

finish_tests
