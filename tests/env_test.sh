#!/usr/bin/env bash
set -u

source "$(dirname "${BASH_SOURCE[0]}")/helper.bash"
source "$SHLIB_ROOT/env.sh"

test_env_defined_set_require_default() {
    local present="value"
    local empty=""
    unset missing || :

    assert_success env_defined present
    assert_success env_defined empty
    assert_failure env_defined missing

    assert_success env_set present
    assert_failure env_set empty
    assert_failure env_set missing

    env_require present
    capture_subshell env_require missing
    assert_eq "1" "$SHLIB_CAPTURE_STATUS"
    assert_contains "$SHLIB_CAPTURE_OUTPUT" "missing environment variable: missing"

    env_default empty fallback
    assert_eq "fallback" "$empty"
    env_default present changed
    assert_eq "value" "$present"
}

test_env_bool() {
    local flag

    # shellcheck disable=SC2034
    flag=true
    assert_success env_bool flag
    # shellcheck disable=SC2034
    flag=YES
    assert_success env_bool flag
    # shellcheck disable=SC2034
    flag=on
    assert_success env_bool flag
    # shellcheck disable=SC2034
    flag=0
    assert_failure env_bool flag
    unset flag || :
    assert_failure env_bool flag
}

test_env_load_dotenv() {
    local tmpdir file
    tmpdir="$(mktemp -d)"
    file="$tmpdir/.env"
    trap 'rm -rf "$tmpdir"' RETURN

    cat > "$file" <<'EOF'
# comment
NAME=ivan
EMPTY=
QUOTED="two words"
SINGLE='one value'
EOF

    env_load_dotenv "$file"

    assert_eq "ivan" "${NAME-}"
    assert_eq "" "${EMPTY-}"
    assert_eq "two words" "${QUOTED-}"
    assert_eq "one value" "${SINGLE-}"

    printf 'bad line\n' > "$file"
    assert_failure env_load_dotenv "$file"
}

run_test "environment defined, set, require, and default" test_env_defined_set_require_default
run_test "environment boolean parsing" test_env_bool
run_test "dotenv loading" test_env_load_dotenv

finish_tests
