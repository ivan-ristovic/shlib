#!/usr/bin/env bash
set -u

source "$(dirname "${BASH_SOURCE[0]}")/helper.bash"
source "$SHLIB_ROOT/url.sh"

test_url_codec() {
    assert_command_output "a%20b%2Bc%3F" url_encode "a b+c?"
    assert_command_output "a b c?" url_decode "a%20b+c%3F"
}

test_url_query_get() {
    assert_command_output "two words" url_query_get "name" "id=1&name=two+words"
    assert_command_output "x=y" url_query_get "raw" "?raw=x%3Dy&empty="
    assert_command_output "" url_query_get "empty" "?raw=x%3Dy&empty="
    assert_failure url_query_get "missing" "id=1"
}

test_url_query_set() {
    assert_command_output "id=1&name=two%20words" url_query_set "name" "two words" "id=1"
    assert_command_output "?id=1&name=updated" url_query_set "name" "updated" "?id=1&name=old"
    assert_command_output "name=one" url_query_set "name" "one" "name=old&name=older"
}

run_test "URL encode and decode" test_url_codec
run_test "URL query get" test_url_query_get
run_test "URL query set" test_url_query_set

finish_tests
