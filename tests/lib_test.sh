#!/usr/bin/env bash
set -u

source "$(dirname "${BASH_SOURCE[0]}")/helper.bash"

test_lib_loader_sources_all_modules() {
    source "$SHLIB_ROOT/lib.sh"

    assert_success test_fn_defined str_len
    assert_success test_fn_defined arr_append
    assert_success test_fn_defined assert_pass
    assert_success test_fn_defined cmd_exists
    assert_success test_fn_defined env_defined
    assert_success test_fn_defined fs_exists
    assert_success test_fn_defined io_readline
    assert_success test_fn_defined kv_get
    assert_success test_fn_defined log_msg
    assert_success test_fn_defined math_eval
    assert_success test_fn_defined net_is_ipv4
    assert_success test_fn_defined os_path
    assert_success test_fn_defined semver_cmp
    assert_success test_fn_defined std_usage
    assert_success test_fn_defined test_assert_eq
    assert_success test_fn_defined time_now
    assert_success test_fn_defined url_encode
    assert_success test_fn_defined ansi_ansi
}

run_test "loader sources all modules" test_lib_loader_sources_all_modules

finish_tests
