#!/usr/bin/env bash
set -u

source "$(dirname "${BASH_SOURCE[0]}")/helper.bash"
source "$SHLIB_ROOT/time.sh"

test_time_now() {
    local now
    now="$(time_now)"
    assert_match "$now" '^[0-9]{10,}$'
}

test_date_now() {
    local today
    today="$(date_now)"
    assert_match "$today" '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
}

run_test "Unix timestamp" test_time_now
run_test "ISO date" test_date_now

finish_tests
