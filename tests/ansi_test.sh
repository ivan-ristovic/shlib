#!/usr/bin/env bash
set -u

source "$(dirname "${BASH_SOURCE[0]}")/helper.bash"
source "$SHLIB_ROOT/ansi.sh"

ESC=$'\033'
CSI="${ESC}["
OSC="${ESC}]"
ST="${ESC}\\"

test_ansi_misc_cursor_and_screen() {
    assert_command_output $'\a' ansi_bell
    assert_command_output "${CSI}4b" ansi_repeat 4
    assert_command_output "${CSI}0m${CSI}10m${CSI}2J${CSI}1;1H${CSI}?25h" ansi_reset

    assert_command_output "${CSI}u" ansi_cur_restore
    assert_command_output "${CSI}2;3H" ansi_cur_pos "2,3"
    assert_command_output "${CSI}s" ansi_cur_pos_save
    assert_command_output "${CSI}5C" ansi_cur_fw 5
    assert_command_output "${CSI}2I" ansi_cur_fw_tab 2
    assert_command_output "${CSI}4D" ansi_cur_bw 4
    assert_command_output "${CSI}3Z" ansi_cur_bw_tab 3
    assert_command_output "${CSI}6B" ansi_cur_dn 6
    assert_command_output "${CSI}7A" ansi_cur_up 7
    assert_command_output "${CSI}5m" ansi_cur_blink
    assert_command_output "${CSI}6m" ansi_cur_blink_rapid
    assert_command_output "${CSI}25m" ansi_cur_blink_off
    assert_command_output "${CSI}9G" ansi_cur_col 9
    assert_command_output "${CSI}8a" ansi_cur_col_rel 8
    assert_command_output "${CSI}?25l" ansi_cur_hide
    assert_command_output "${CSI}?25h" ansi_cur_show
    assert_command_output "${CSI}10d" ansi_cur_lf 10
    assert_command_output "${CSI}11e" ansi_cur_lf_rel 11
    assert_command_output "${CSI}12E" ansi_cur_nl 12
    assert_command_output "${CSI}13F" ansi_cur_prev_line 13
    assert_command_output "${CSI}14T" ansi_scr_down 14
    assert_command_output "${CSI}15S" ansi_scr_up 15
}

test_ansi_insert_delete_erase() {
    assert_command_output "${CSI}2@" ansi_ins_chars 2
    assert_command_output "${CSI}3L" ansi_ins_lines 3
    assert_command_output "${CSI}4P" ansi_del_chars 4
    assert_command_output "${CSI}5M" ansi_del_lines 5
    assert_command_output "${CSI}2J" ansi_erase_display 2
    assert_command_output "${CSI}6X" ansi_erase_chars 6
    assert_command_output "${CSI}7K" ansi_erase_lines 7
}

test_ansi_format_and_font() {
    assert_command_output "${CSI}0m" ansi_fmt_reset
    assert_command_output "${CSI}1m" ansi_fmt_bold
    assert_command_output "${CSI}22m" ansi_fmt_bold_off
    assert_command_output "${CSI}3m" ansi_fmt_italic
    assert_command_output "${CSI}23m" ansi_fmt_italic_off
    assert_command_output "${CSI}20m" ansi_fmt_fraktur
    assert_command_output "${CSI}4m" ansi_fmt_underline
    assert_command_output "${CSI}21m" ansi_fmt_underline2
    assert_command_output "${CSI}9m" ansi_fmt_strike
    assert_command_output "${CSI}29m" ansi_fmt_strike_off
    assert_command_output "${CSI}24m" ansi_fmt_underline_off
    assert_command_output "${CSI}2m" ansi_fmt_faint
    assert_command_output "${CSI}7m" ansi_fmt_inverse
    assert_command_output "${CSI}27m" ansi_fmt_inverse_off
    assert_command_output "${CSI}8m" ansi_fmt_invisible
    assert_command_output "${CSI}28m" ansi_fmt_visible
    assert_command_output "${OSC}1;icon${ST}" ansi_fmt_icon "icon"
    assert_command_output "${OSC}2;title${ST}" ansi_fmt_title "title"
    assert_command_output "${CSI}13m" ansi_font 3
    assert_command_output "${CSI}10m" ansi_font_reset
}

test_ansi_foreground_colors() {
    assert_command_output "${CSI}39m" ansi_fg_reset
    assert_command_output "${CSI}38;5;123m" ansi_fg 123
    assert_command_output "${CSI}38;2;1;2;3m" ansi_fg_rgb 1 2 3
    assert_command_output "${CSI}30m" ansi_fg_black
    assert_command_output "${CSI}90m" ansi_fg_black_i
    assert_command_output "${CSI}34m" ansi_fg_blue
    assert_command_output "${CSI}94m" ansi_fg_blue_i
    assert_command_output "${CSI}36m" ansi_fg_cyan
    assert_command_output "${CSI}96m" ansi_fg_cyan_i
    assert_command_output "${CSI}32m" ansi_fg_green
    assert_command_output "${CSI}92m" ansi_fg_green_i
    assert_command_output "${CSI}35m" ansi_fg_magenta
    assert_command_output "${CSI}95m" ansi_fg_magenta_i
    assert_command_output "${CSI}31m" ansi_fg_red
    assert_command_output "${CSI}91m" ansi_fg_red_i
    assert_command_output "${CSI}37m" ansi_fg_white
    assert_command_output "${CSI}97m" ansi_fg_white_i
    assert_command_output "${CSI}33m" ansi_fg_yellow
    assert_command_output "${CSI}93m" ansi_fg_yellow_i
}

test_ansi_background_colors() {
    assert_command_output "${CSI}49m" ansi_bg_reset
    assert_command_output "${CSI}48;5;45m" ansi_bg 45
    assert_command_output "${CSI}48;2;4;5;6m" ansi_bg_rgb 4 5 6
    assert_command_output "${CSI}40m" ansi_bg_black
    assert_command_output "${CSI}100m" ansi_bg_black_i
    assert_command_output "${CSI}44m" ansi_bg_blue
    assert_command_output "${CSI}104m" ansi_bg_blue_i
    assert_command_output "${CSI}46m" ansi_bg_cyan
    assert_command_output "${CSI}106m" ansi_bg_cyan_i
    assert_command_output "${CSI}42m" ansi_bg_green
    assert_command_output "${CSI}102m" ansi_bg_green_i
    assert_command_output "${CSI}45m" ansi_bg_magenta
    assert_command_output "${CSI}105m" ansi_bg_magenta_i
    assert_command_output "${CSI}41m" ansi_bg_red
    assert_command_output "${CSI}101m" ansi_bg_red_i
    assert_command_output "${CSI}47m" ansi_bg_white
    assert_command_output "${CSI}107m" ansi_bg_white_i
    assert_command_output "${CSI}43m" ansi_bg_yellow
    assert_command_output "${CSI}103m" ansi_bg_yellow_i
}

test_ansi_ideogram_and_frames() {
    assert_command_output "${CSI}62m" ansi_ig_left
    assert_command_output "${CSI}63m" ansi_ig_left2
    assert_command_output "${CSI}60m" ansi_ig_right
    assert_command_output "${CSI}61m" ansi_ig_right2
    assert_command_output "${CSI}64m" ansi_ig_stress
    assert_command_output "${CSI}65m" ansi_ig_reset
    assert_command_output "${CSI}52m" ansi_frame_encircle
    assert_command_output "${CSI}51m" ansi_frame
    assert_command_output "${CSI}54m" ansi_frame_reset
    assert_command_output "${CSI}53m" ansi_frame_overline
    assert_command_output "${CSI}55m" ansi_frame_overline_off
}

test_ansi_reports() {
    local -a values=("P" "a" "b" "Z")

    # shellcheck disable=SC2329
    read() {
        local var="${*: -1}"
        printf -v "$var" '%s' "${values[0]}"
        values=("${values[@]:1}")
    }

    ANSI_REPORT=
    ansi_report "q" "P" "Z"
    assert_eq "ab" "$ANSI_REPORT"
    assert_eq "0" "${#values[@]}"
}

test_ansi_report_helpers() {
    # shellcheck disable=SC2329
    ansi_report() {
        ANSI_REPORT="$SHLIB_REPORT_VALUE"
    }

    SHLIB_REPORT_VALUE="12;34"
    assert_command_output "12,34" ansi_report_pos
    assert_command_output "12,34" ansi_report_icon
    assert_command_output "12,34" ansi_report_screen_chars
    assert_command_output "12,34" ansi_report_title
    assert_command_output "12,34" ansi_report_window_chars
    assert_command_output "12,34" ansi_report_window_pixels
    assert_command_output "12,34" ansi_report_window_pos

    SHLIB_REPORT_VALUE="1"
    assert_command_output "open" ansi_report_window_state
    SHLIB_REPORT_VALUE="2"
    assert_command_output "iconified" ansi_report_window_state
    SHLIB_REPORT_VALUE="9"
    assert_command_output "unknown (9)" ansi_report_window_state
}

test_ansi_support_help_and_wrapper() {
    local output

    ANSI_FORCE_SUPPORT=1 assert_success ansi_is_supported

    output="$(ansi_help)"
    assert_contains "$output" "Usage: ansi_ansi"

    output="$(ANSI_FORCE_SUPPORT=1 ansi_ansi --no-restore -n --red "red")"
    assert_eq "${CSI}31mred" "$output"

    output="$(ANSI_FORCE_SUPPORT=1 ansi_ansi --bold "bold"; printf sentinel)"
    assert_eq "${CSI}1mbold${CSI}22m"$'\n'"sentinel" "$output"

    output="$(ANSI_FORCE_SUPPORT=1 ansi_ansi --no-restore -n --rgb=1,2,3 --bg-rgb=4,5,6 "rgb")"
    assert_eq "${CSI}38;2;1;2;3m${CSI}48;2;4;5;6mrgb" "$output"

    output="$(ANSI_FORCE_SUPPORT=1 ansi_ansi --no-restore -n --save-cursor --hide-cursor "x")"
    assert_eq "${CSI}s${CSI}?25lx" "$output"

    # shellcheck disable=SC2329
    ansi_report_pos() {
        printf '7,9\n'
    }

    output="$(ANSI_FORCE_SUPPORT=1 ansi_ansi --report-position)"
    assert_eq "7,9" "$output"
}

run_test "ANSI misc, cursor, and screen sequences" test_ansi_misc_cursor_and_screen
run_test "ANSI insert, delete, and erase sequences" test_ansi_insert_delete_erase
run_test "ANSI format and font sequences" test_ansi_format_and_font
run_test "ANSI foreground colors" test_ansi_foreground_colors
run_test "ANSI background colors" test_ansi_background_colors
run_test "ANSI ideogram and frame sequences" test_ansi_ideogram_and_frames
run_test "ANSI low-level report parser" test_ansi_reports
run_test "ANSI report helpers" test_ansi_report_helpers
run_test "ANSI support, help, and wrapper" test_ansi_support_help_and_wrapper

finish_tests
