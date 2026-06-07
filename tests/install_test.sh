#!/usr/bin/env bash
set -u

source "$(dirname "${BASH_SOURCE[0]}")/helper.bash"

test_install_user_prefix() {
    local tmpdir prefix target output
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' RETURN
    prefix="$tmpdir/prefix"
    target="$prefix/lib/shlib"

    output="$("$SHLIB_REPO_ROOT/install" --user --prefix "$prefix")"

    assert_success test -L "$target"
    assert_command_output "$SHLIB_ROOT" readlink "$target"
    assert_contains "$output" "installed: $target -> $SHLIB_ROOT"
    assert_contains "$output" "export SHLIB_ROOT="
}

test_install_system_prefix() {
    local tmpdir prefix target output
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' RETURN
    prefix="$tmpdir/system"
    target="$prefix/lib/shlib"

    output="$("$SHLIB_REPO_ROOT/install" --system --prefix "$prefix")"

    assert_success test -L "$target"
    assert_command_output "$SHLIB_ROOT" readlink "$target"
    assert_contains "$output" "installed: $target -> $SHLIB_ROOT"
}

test_install_existing_target_requires_force() {
    local tmpdir prefix target output
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' RETURN
    prefix="$tmpdir/prefix"
    target="$prefix/lib/shlib"
    mkdir -p "${target%/*}"
    printf 'old\n' > "$target"

    capture_subshell "$SHLIB_REPO_ROOT/install" --user --prefix "$prefix"
    assert_eq "1" "$SHLIB_CAPTURE_STATUS"
    assert_contains "$SHLIB_CAPTURE_OUTPUT" "target already exists: $target"

    output="$("$SHLIB_REPO_ROOT/install" --user --prefix "$prefix" --force)"

    assert_success test -L "$target"
    assert_command_output "$SHLIB_ROOT" readlink "$target"
    assert_contains "$output" "installed: $target -> $SHLIB_ROOT"
}

test_install_dry_run() {
    local tmpdir prefix target output
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' RETURN
    prefix="$tmpdir/prefix"
    target="$prefix/lib/shlib"

    output="$("$SHLIB_REPO_ROOT/install" --user --prefix "$prefix" --dry-run)"

    assert_failure test -e "$target"
    assert_contains "$output" "would symlink: $target -> $SHLIB_ROOT"
}

run_test "install script user prefix" test_install_user_prefix
run_test "install script system prefix" test_install_system_prefix
run_test "install script force handling" test_install_existing_target_requires_force
run_test "install script dry run" test_install_dry_run

finish_tests
