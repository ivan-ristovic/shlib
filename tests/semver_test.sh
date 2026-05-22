#!/usr/bin/env bash
set -u

source "$(dirname "${BASH_SOURCE[0]}")/helper.bash"
source "$SHLIB_ROOT/semver.sh"

test_semver_parse_and_cmp() {
    assert_command_output "1 2 3" semver_parse "1.2.3"
    assert_command_output "1 2 3" semver_parse "01.002.0003"
    assert_failure semver_parse "1.2"

    assert_command_output "-1" semver_cmp "1.2.3" "1.2.4"
    assert_command_output "0" semver_cmp "1.2.3" "1.2.3"
    assert_command_output "1" semver_cmp "2.0.0" "1.9.9"
    assert_failure semver_cmp "bad" "1.0.0"
}

test_semver_predicates() {
    assert_success semver_eq "1.2.3" "1.2.3"
    assert_failure semver_eq "1.2.3" "1.2.4"
    assert_success semver_lt "1.2.3" "1.2.4"
    assert_success semver_le "1.2.3" "1.2.3"
    assert_success semver_gt "2.0.0" "1.9.9"
    assert_success semver_ge "2.0.0" "2.0.0"
    assert_failure semver_gt "1.0.0" "2.0.0"
}

run_test "semantic version parse and compare" test_semver_parse_and_cmp
run_test "semantic version predicates" test_semver_predicates

finish_tests
