#!/usr/bin/env bash
set -u

source "$(dirname "${BASH_SOURCE[0]}")/helper.bash"
source "$SHLIB_ROOT/math.sh"

test_math_basic_eval() {
    assert_command_output "3" math_int "3.14"
    assert_command_output ".14" math_frac "3.14"
    assert_command_output "3.00" math_compute "sqrt(9)" 2
    assert_command_output ".500" math_eval "1/2" 3
    assert_success math_cond "1"
    assert_failure math_cond "0"
    assert_failure math_cond "2"
}

test_math_trig() {
    assert_command_output ".84" math_sin 1 2
    assert_command_output ".54" math_cos 1 2
    assert_command_output "1.55" math_tan 1 2
    assert_command_output ".64" math_cotan 1 2
    assert_command_output "1.85" math_sec 1 2
    assert_command_output "1.19" math_cosec 1 2
    assert_command_output "1.19" math_csc 1 2
}

test_math_inverse_trig() {
    assert_command_output ".50" math_asin .5 2
    assert_command_output "1.02" math_acos .5 2
    assert_command_output ".78" math_atan 1 2
    assert_command_output ".79" math_arccot 1 2
    assert_command_output ".50" math_arcsin .5 2
    assert_command_output "1.02" math_arccos .5 2
    assert_command_output ".78" math_arctan 1 2
}

test_math_logs_exponents_and_angles() {
    assert_command_output ".69" math_ln 2 2
    assert_command_output "2.00" math_log10 100 2
    assert_command_output "2.00" math_log 100 2
    assert_command_output "2.71" math_exp 1 2
    assert_command_output "8" math_pow 2 3 2
    assert_command_output "180.00" math_deg "$PI" 2
    assert_command_output "0" math_ndeg 0 2
    assert_command_output "3.14" math_rad 180 2
}

test_math_misc() {
    assert_command_output "5" math_abs -5
    assert_command_output "5.00" math_hypot 3 4 2
    assert_command_output "3.15" math_round 3.145 2
}

run_test "basic numeric evaluation" test_math_basic_eval
run_test "trigonometric helpers" test_math_trig
run_test "inverse trigonometric helpers" test_math_inverse_trig
run_test "logs, powers, and angle conversion" test_math_logs_exponents_and_angles
run_test "miscellaneous math helpers" test_math_misc

finish_tests
