#!/usr/bin/env bash
# shellcheck disable=SC2317
set -u

source "$(dirname "${BASH_SOURCE[0]}")/helper.bash"
source "$SHLIB_ROOT/prompt.sh"

test_prompt_confirm() {
    local tmpdir tty status
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' RETURN

    tty="$tmpdir/default-yes"
    printf '\n' > "$tty"
    SHLIB_PROMPT_TTY="$tty" prompt_confirm "Continue?" yes >/dev/null

    tty="$tmpdir/default-no"
    printf '\n' > "$tty"
    set +e
    SHLIB_PROMPT_TTY="$tty" prompt_confirm "Continue?" no >/dev/null
    status=$?
    set -e
    assert_eq "1" "$status"

    tty="$tmpdir/no"
    printf 'n\n' > "$tty"
    set +e
    SHLIB_PROMPT_TTY="$tty" prompt_confirm "Continue?" required >/dev/null
    status=$?
    set -e
    assert_eq "1" "$status"

    capture_subshell prompt_confirm "Continue?" maybe
    assert_eq "2" "$SHLIB_CAPTURE_STATUS"
    assert_contains "$SHLIB_CAPTURE_OUTPUT" "invalid confirm mode"
}

test_prompt_input() {
    local tmpdir tty answer
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' RETURN

    tty="$tmpdir/default"
    printf '\n' > "$tty"
    SHLIB_PROMPT_TTY="$tty" prompt_input answer "Name" "ivan" >/dev/null
    assert_eq "ivan" "$answer"

    tty="$tmpdir/value"
    printf 'ana\n' > "$tty"
    SHLIB_PROMPT_TTY="$tty" prompt_input answer "Name" "ivan" >/dev/null
    assert_eq "ana" "$answer"
}

test_prompt_select() {
    local tmpdir tty answer
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' RETURN

    tty="$tmpdir/select"
    printf '2\n' > "$tty"
    SHLIB_PROMPT_TTY="$tty" prompt_select answer "Choose" alpha beta gamma >/dev/null
    assert_eq "beta" "$answer"

    capture_subshell prompt_select answer "Choose"
    assert_eq "2" "$SHLIB_CAPTURE_STATUS"
    assert_contains "$SHLIB_CAPTURE_OUTPUT" "requires at least one option"
}

run_test "confirm prompts" test_prompt_confirm
run_test "input prompts" test_prompt_input
run_test "select prompts" test_prompt_select

finish_tests
