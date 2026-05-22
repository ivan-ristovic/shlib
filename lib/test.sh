#!/bin/bash

SHLIB_TESTS="${SHLIB_TESTS:-0}"
SHLIB_FAILURES="${SHLIB_FAILURES:-0}"
SHLIB_CURRENT_TEST="${SHLIB_CURRENT_TEST:-}"

function _test_quote ()
{
    printf '%q' "$1"
}

function _test_fail ()
{
    printf 'not ok - %s: %s\n' "$SHLIB_CURRENT_TEST" "$*" >&2
    if [[ -n "${SHLIB_FAILURE_MARKER:-}" ]]; then
        printf '1\n' >> "$SHLIB_FAILURE_MARKER"
    fi
    return 1
}

# Assert that two strings are equal.
# Inputs:
#   $1 - Expected string.
#   $2 - Actual string.
#
# Output:
#   Writes a test failure line to stderr when values differ.
#
# Returns:
#   0 when values match; 1 when they differ.
#
# Example:
#   test_assert_eq "ok" "$status"
function test_assert_eq ()
{
    local expected="$1" actual="$2"
    if [[ "$actual" != "$expected" ]]; then
        _test_fail "expected $(_test_quote "$expected"), got $(_test_quote "$actual")"
        return 1
    fi
}

# Assert that two strings are not equal.
# Inputs:
#   $1 - Unexpected string.
#   $2 - Actual string.
#
# Output:
#   Writes a test failure line to stderr when values match.
#
# Returns:
#   0 when values differ; 1 when they match.
#
# Example:
#   test_assert_ne "" "$token"
function test_assert_ne ()
{
    local unexpected="$1" actual="$2"
    if [[ "$actual" == "$unexpected" ]]; then
        _test_fail "did not expect $(_test_quote "$actual")"
        return 1
    fi
}

# Assert that text contains a substring.
# Inputs:
#   $1 - Haystack text.
#   $2 - Required substring.
#
# Output:
#   Writes a test failure line to stderr when the substring is missing.
#
# Returns:
#   0 when found; 1 otherwise.
#
# Example:
#   test_assert_contains "$output" "usage:"
function test_assert_contains ()
{
    local haystack="$1" needle="$2"
    if [[ "$haystack" != *"$needle"* ]]; then
        _test_fail "expected $(_test_quote "$haystack") to contain $(_test_quote "$needle")"
        return 1
    fi
}

# Assert that text matches a Bash regex.
# Inputs:
#   $1 - Text to test.
#   $2 - Bash regular expression.
#
# Output:
#   Writes a test failure line to stderr when the regex does not match.
#
# Returns:
#   0 when matched; 1 otherwise.
#
# Example:
#   test_assert_match "$date" '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
function test_assert_match ()
{
    local actual="$1" regex="$2"
    if [[ ! "$actual" =~ $regex ]]; then
        _test_fail "expected $(_test_quote "$actual") to match $regex"
        return 1
    fi
}

# Assert that a command exits with an expected status.
# Inputs:
#   $1 - Expected status code.
#   $@ - Command and arguments after the status.
#
# Output:
#   Writes a test failure line to stderr when the status differs.
#
# Returns:
#   0 when the status matches; 1 otherwise.
#
# Example:
#   test_assert_status 2 args_parse spec opts pos --bad
function test_assert_status ()
{
    local expected="$1" actual
    shift

    set +e
    "$@"
    actual=$?
    set -e

    if (( actual != expected )); then
        _test_fail "expected status $expected, got $actual from $*"
        return 1
    fi
}

# Assert that a command succeeds.
# Inputs:
#   $@ - Command and arguments to run.
#
# Output:
#   Writes a test failure line to stderr when the command fails.
#
# Returns:
#   0 when the command returns 0; 1 otherwise.
#
# Example:
#   test_assert_success mkdir -p "$tmpdir"
function test_assert_success ()
{
    test_assert_status 0 "$@"
}

# Assert that a command fails.
# Inputs:
#   $@ - Command and arguments to run.
#
# Output:
#   Writes a test failure line to stderr when the command succeeds.
#
# Returns:
#   0 when the command returns non-zero; 1 otherwise.
#
# Example:
#   test_assert_failure test -e "$missing"
function test_assert_failure ()
{
    local actual

    set +e
    "$@"
    actual=$?
    set -e

    if (( actual == 0 )); then
        _test_fail "expected failure from $*"
        return 1
    fi
}

# Assert that command stdout equals an expected string.
# Inputs:
#   $1 - Expected stdout.
#   $@ - Command and arguments after the expected value.
#
# Output:
#   Writes a test failure line to stderr when output differs.
#
# Returns:
#   0 when stdout matches; 1 otherwise.
#
# Example:
#   test_assert_command_output "hello" printf hello
function test_assert_command_output ()
{
    local expected="$1" actual
    shift

    actual="$("$@")"
    test_assert_eq "$expected" "$actual"
}

# Capture command output and status for later assertions.
# Inputs:
#   $@ - Command and arguments to run.
#
# Output:
#   Assigns SHLIB_CAPTURE_OUTPUT and SHLIB_CAPTURE_STATUS in the caller scope.
#
# Returns:
#   0; command failure is recorded in SHLIB_CAPTURE_STATUS.
#
# Example:
#   test_capture_subshell missing_command
function test_capture_subshell ()
{
    set +e
    # shellcheck disable=SC2034
    SHLIB_CAPTURE_OUTPUT="$(
        SHLIB_FAILURE_MARKER=
        "$@" 2>&1
    )"
    # shellcheck disable=SC2034
    SHLIB_CAPTURE_STATUS=$?
    set -e
}

# Run a Bash script string and assert its exit status.
# Inputs:
#   $1 - Expected exit status.
#   $2 - Script string passed to bash -c.
#
# Output:
#   Writes a test failure line to stderr when the status differs.
#
# Returns:
#   0 when the status matches; 1 otherwise.
#
# Example:
#   test_assert_subshell_status 1 'source "$SHLIB_ROOT/std.sh"; std_fat bad'
function test_assert_subshell_status ()
{
    local expected="$1" script="$2" tmp actual output

    tmp="$(mktemp)"
    set +e
    SHLIB_ROOT="$SHLIB_ROOT" bash -c "$script" >"$tmp" 2>&1
    actual=$?
    set -e

    if (( actual != expected )); then
        output="$(cat "$tmp")"
        rm -f -- "$tmp"
        _test_fail "expected subprocess status $expected, got $actual; output: $(_test_quote "$output")"
        return 1
    fi

    rm -f -- "$tmp"
}

# Run one test function and record the result.
# Inputs:
#   $1 - Human-readable test name.
#   $2 - Test function name.
#
# Output:
#   Writes "ok - NAME" to stdout on success; failures are written by assertions.
#
# Returns:
#   0; failure counts are recorded in SHLIB_FAILURES.
#
# Example:
#   test_run "string length" test_str_len
function test_run ()
{
    local name="$1" fn="$2" marker status

    SHLIB_TESTS=$((SHLIB_TESTS + 1))
    SHLIB_CURRENT_TEST="$name"
    marker="$(mktemp)"

    (
        SHLIB_CURRENT_TEST="$name"
        SHLIB_FAILURE_MARKER="$marker"
        "$fn"
    )
    status=$?

    if (( status == 0 )) && [[ ! -s "$marker" ]]; then
        printf 'ok - %s\n' "$name"
    else
        SHLIB_FAILURES=$((SHLIB_FAILURES + 1))
    fi

    rm -f -- "$marker"
}

# Print the test summary and return aggregate status.
# Inputs:
#   None.
#
# Output:
#   Writes "N tests, M failures" to stdout.
#
# Returns:
#   0 when no failures were recorded; 1 otherwise.
#
# Example:
#   test_finish
function test_finish ()
{
    printf '%s tests, %s failures\n' "$SHLIB_TESTS" "$SHLIB_FAILURES"
    (( SHLIB_FAILURES == 0 ))
}
