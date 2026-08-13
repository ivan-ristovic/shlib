#!/usr/bin/env bash
# shellcheck disable=SC2317
set -u

source "$(dirname "${BASH_SOURCE[0]}")/helper.bash"
source "$SHLIB_ROOT/io.sh"

test_io_path_predicates() {
    local tmpdir file
    tmpdir="$(mktemp -d)"
    file="$tmpdir/file.txt"
    printf 'data' > "$file"
    trap 'rm -rf "$tmpdir"' RETURN

    assert_success io_is_dir "$tmpdir"
    assert_failure io_is_dir "$file"
    assert_success io_is_file "$file"
    assert_failure io_is_file "$tmpdir"
    assert_failure io_is_dev "$file"
}

test_io_readline_reads_final_record_without_delimiter() {
    local tmpdir file
    local lines=()
    local line

    tmpdir="$(mktemp -d)"
    file="$tmpdir/input.txt"
    printf 'one\ntwo\nthree' > "$file"
    trap 'rm -rf "$tmpdir"' RETURN

    while io_readline line; do
        # shellcheck disable=SC2031
        lines+=("$line")
    done < "$file"

    assert_eq "3" "${#lines[@]}"
    assert_eq "one" "${lines[0]}"
    assert_eq "two" "${lines[1]}"
    assert_eq "three" "${lines[2]}"
}

test_io_readline_custom_delimiter_and_fd() {
    local tmpdir file line
    tmpdir="$(mktemp -d)"
    file="$tmpdir/input.txt"
    printf 'alpha:beta:' > "$file"
    trap 'rm -rf "$tmpdir"' RETURN

    exec {fd}< "$file"
    io_readline --delim ':' --fd "$fd" line
    # shellcheck disable=SC2031
    assert_eq "alpha" "$line"
    io_readline --delim ':' --fd "$fd" line
    # shellcheck disable=SC2031
    assert_eq "beta" "$line"
    exec {fd}<&-
}

test_io_readlines() {
    local -a lines=()

    io_readlines lines < <(printf 'red\nblue\nlast')

    assert_eq "3" "${#lines[@]}"
    assert_eq "red" "${lines[0]}"
    assert_eq "blue" "${lines[1]}"
    assert_eq "last" "${lines[2]}"
}

run_test "path predicates" test_io_path_predicates
run_test "readline keeps final unterminated record" test_io_readline_reads_final_record_without_delimiter
run_test "readline delimiter and fd options" test_io_readline_custom_delimiter_and_fd
run_test "readlines fills array" test_io_readlines

finish_tests
