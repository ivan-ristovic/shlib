#!/usr/bin/env bash
# shellcheck disable=SC2317
set -u

source "$(dirname "${BASH_SOURCE[0]}")/helper.bash"
source "$SHLIB_ROOT/config.sh"

test_config_load_get_set() {
    local tmpdir file
    local -A config=()
    tmpdir="$(mktemp -d)"
    file="$tmpdir/app.conf"
    trap 'rm -rf "$tmpdir"' RETURN

    cat > "$file" <<'EOF'
# comment
NAME=ivan
CITY=Belgrade
EMPTY=
EOF

    config_load "$file" config

    assert_command_output "ivan" config_get config NAME
    assert_command_output "Belgrade" config_get config CITY
    assert_command_output "" config_get config EMPTY
    assert_command_output "fallback" config_get config MISSING fallback
    assert_failure config_get config MISSING

    config_set config CITY NoviSad
    assert_command_output "NoviSad" config_get config CITY
}

test_config_errors() {
    local tmpdir file
    # shellcheck disable=SC2034
    local -A config=()
    tmpdir="$(mktemp -d)"
    file="$tmpdir/app.conf"
    trap 'rm -rf "$tmpdir"' RETURN

    assert_failure config_load "$tmpdir/missing" config

    printf 'bad line\n' > "$file"
    capture_subshell config_load "$file" config
    assert_eq "2" "$SHLIB_CAPTURE_STATUS"

    printf 'BAD-KEY=value\n' > "$file"
    capture_subshell config_load "$file" config
    assert_eq "2" "$SHLIB_CAPTURE_STATUS"

    capture_subshell config_set config BAD-KEY value
    assert_eq "2" "$SHLIB_CAPTURE_STATUS"
}

run_test "config load, get, and set" test_config_load_get_set
run_test "config errors" test_config_errors

finish_tests
