#!/usr/bin/env bash
# shellcheck disable=SC2317
set -u

source "$(dirname "${BASH_SOURCE[0]}")/helper.bash"
source "$SHLIB_ROOT/kv.sh"

test_kv_get_has_keys() {
    local tmpdir file
    tmpdir="$(mktemp -d)"
    file="$tmpdir/config"
    trap 'rm -rf "$tmpdir"' RETURN

    cat > "$file" <<'EOF'
# comment
NAME=ivan
CITY=Belgrade
BAD-KEY=ignored
EOF

    assert_command_output "ivan" kv_get NAME "$file"
    assert_command_output "Belgrade" kv_get CITY "$file"
    assert_failure kv_get MISSING "$file"
    assert_success kv_has NAME "$file"
    assert_failure kv_has MISSING "$file"
    assert_command_output $'NAME\nCITY' kv_keys "$file"
}

test_kv_set() {
    local tmpdir file
    tmpdir="$(mktemp -d)"
    file="$tmpdir/config"
    trap 'rm -rf "$tmpdir"' RETURN

    kv_set NAME ivan "$file"
    kv_set CITY Belgrade "$file"
    kv_set NAME updated "$file"

    assert_command_output "updated" kv_get NAME "$file"
    assert_command_output "Belgrade" kv_get CITY "$file"
    assert_eq $'NAME=updated\nCITY=Belgrade' "$(cat "$file")"
    assert_failure kv_set BAD-KEY value "$file"
}

run_test "key/value get, has, and keys" test_kv_get_has_keys
run_test "key/value set and update" test_kv_set

finish_tests
