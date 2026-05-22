#!/usr/bin/env bash
set -u

source "$(dirname "${BASH_SOURCE[0]}")/helper.bash"
source "$SHLIB_ROOT/log.sh"

test_log_levels() {
    assert_command_output $'\033[0;34m[inf]: \033[0mhello' log_msg "hello"
    assert_command_output $'\033[0;32m[suc]: \033[0mdone' log_suc "done"
    assert_command_output $'\033[0;33m[WRN]: \033[0mcareful' log_wrn "careful"
    assert_command_output $'\033[0;31m[ERR]: \033[0mbad' log_err "bad"
    assert_command_output $'\033[0;31m[CUSTOM]: \033[0mvalue' log_log "CUSTOM" "$SHLIB_FMT_C_R" "value"
}

test_log_debug_gate() {
    # shellcheck disable=SC2034
    SHLIB_LOG_DEBUG=false
    assert_command_output "" log_dbg "hidden"

    # shellcheck disable=SC2034
    SHLIB_LOG_DEBUG=true
    assert_command_output $'\033[0;34m[dbg]: \033[0mshown' log_dbg "shown"
}

test_log_exec_and_time() {
    local output

    output="$(log_exec printf "ok")"
    assert_eq $'\033[0;34m[inf]: \033[0mexecuting: printf ok\nok' "$output"

    # shellcheck disable=SC2034
    SHLIB_FMT_TIME=true
    output="$(log_msg "timed")"
    unset SHLIB_FMT_TIME
    assert_match "$output" $'^\033\\[1m\\[[0-9]{2}:[0-9]{2}:[0-9]{2}\\]\033\\[0;34m\\[inf\\]: \033\\[0mtimed$'
}

test_log_stacktrace() {
    local output

    _log_stack_inner() {
        log_stacktrace
    }

    output="$(_log_stack_inner)"
    assert_contains "$output" "_log_stack_inner"
    assert_contains "$output" "log_stacktrace"
}

run_test "log level output" test_log_levels
run_test "debug logging gate" test_log_debug_gate
run_test "exec and time formatting" test_log_exec_and_time
run_test "stacktrace output" test_log_stacktrace

finish_tests
