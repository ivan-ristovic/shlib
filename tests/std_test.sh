#!/usr/bin/env bash
# shellcheck disable=SC2317
set -u

source "$(dirname "${BASH_SOURCE[0]}")/helper.bash"
source "$SHLIB_ROOT/std.sh"

test_std_usage_and_fat_exit() {
    capture_subshell std_usage "ARG"
    assert_eq "1" "$SHLIB_CAPTURE_STATUS"
    assert_contains "$SHLIB_CAPTURE_OUTPUT" "usage:"
    assert_contains "$SHLIB_CAPTURE_OUTPUT" "ARG"

    capture_subshell std_fat "fatal message"
    assert_eq "1" "$SHLIB_CAPTURE_STATUS"
    assert_contains "$SHLIB_CAPTURE_OUTPUT" "fatal message"
}

test_std_ask() {
    local tmpdir tty status
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' RETURN

    tty="$tmpdir/yes"
    printf 'y\n' > "$tty"
    SHLIB_TTY="$tty" SHLIB_ASK_DELAY=0 std_ask "Continue?" >/dev/null

    tty="$tmpdir/no"
    printf 'n\n' > "$tty"
    set +e
    SHLIB_TTY="$tty" SHLIB_ASK_DELAY=0 std_ask "Continue?" >/dev/null
    status=$?
    set -e
    assert_eq "1" "$status"

    tty="$tmpdir/default-yes"
    printf '\n' > "$tty"
    SHLIB_TTY="$tty" SHLIB_ASK_DELAY=0 std_ask "Continue?" Y >/dev/null

    tty="$tmpdir/default-no"
    printf '\n' > "$tty"
    set +e
    SHLIB_TTY="$tty" SHLIB_ASK_DELAY=0 std_ask "Continue?" N >/dev/null
    status=$?
    set -e
    assert_eq "1" "$status"
}

test_std_confirm() {
    local tmpdir marker
    tmpdir="$(mktemp -d)"
    marker="$tmpdir/marker"
    trap 'rm -rf "$tmpdir"' RETURN

    # shellcheck disable=SC2016
    printf 'x' | std_confirm bash -c 'printf done > "$1"' _ "$marker" >/dev/null
    assert_eq "done" "$(cat "$marker")"
}

test_std_beep() {
    local tmpdir marker
    tmpdir="$(mktemp -d)"
    marker="$tmpdir/beep"
    trap 'rm -rf "$tmpdir"' RETURN

    # shellcheck disable=SC2329
    _std_beep_v() {
        printf '%s:%s\n' "$1" "$2" >> "$marker"
    }

    std_beep
    std_beep 440 .2

    assert_eq $'1500:.1\n440:.2' "$(cat "$marker")"
}

run_test "usage and fatal exits" test_std_usage_and_fat_exit
run_test "interactive ask with test tty" test_std_ask
run_test "confirm runs command" test_std_confirm
run_test "beep delegates to helper" test_std_beep

finish_tests
