#!/usr/bin/env bash
#
# ANSI code generator
#
# © Copyright 2015 Tyler Akins, modified for more intuitive naming convention
# Licensed under the MIT license with an additional non-advertising clause
# See http://github.com/fidian/ansi

ANSI_ESC=$'\033'
ANSI_CSI="${ANSI_ESC}["
ANSI_OSC="${ANSI_ESC}]"
ANSI_ST="${ANSI_ESC}\\"
ANSI_REPORT=""


#### MISC ####

# Emit the terminal bell character.
# Inputs: none.
#
# Output: Writes BEL to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_bell
ansi_bell() {
    printf "%s" $'\007'
}

# Repeat the previous printable character.
# Inputs: $1 - Optional repeat count.
#
# Output: Writes CSI Ps b to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_repeat 4
ansi_repeat() {
    printf '%s%sb' "$ANSI_CSI" "${1-}"
}

# Reset common terminal display state.
# Inputs: none.
#
# Output: Writes text reset, font reset, display erase, cursor move, and cursor
#   show sequences to stdout.
#
# Returns: 0 unless one of the underlying print helpers fails.
#
# Example: ansi_reset
ansi_reset() {
    ansi_fmt_reset
    ansi_font_reset
    ansi_erase_display 2
    ansi_cur_pos "1;1"
    ansi_cur_show
}

#### CURSOR ####

# Restore a saved cursor position.
# Inputs: none.
#
# Output: Writes CSI u to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_cur_restore
ansi_cur_restore() {
    printf '%su' "$ANSI_CSI"
}

# Move the cursor to an absolute row and column.
# Inputs: $1 - Position as ROW,COL or ROW;COL.
#
# Output: Writes CSI ROW;COL H to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_cur_pos "10,20"
ansi_cur_pos() {
    local position="${1-}"
    printf '%s%sH' "$ANSI_CSI" "${position/,/;}"
}

# Save the current cursor position.
# Inputs: none.
#
# Output: Writes CSI s to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_cur_pos_save
ansi_cur_pos_save() {
    printf '%ss' "$ANSI_CSI"
}

# Move the cursor forward by columns.
# Inputs: $1 - Optional column count.
#
# Output: Writes CSI Ps C to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_cur_fw 5
ansi_cur_fw() {
    printf '%s%sC' "$ANSI_CSI" "${1-}"
}

# Move the cursor forward by tab stops.
# Inputs: $1 - Optional tab-stop count.
#
# Output: Writes CSI Ps I to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_cur_fw_tab 2
ansi_cur_fw_tab() {
    printf '%s%sI' "$ANSI_CSI" "${1-}"
}

# Move the cursor backward by columns.
# Inputs: $1 - Optional column count.
#
# Output: Writes CSI Ps D to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_cur_bw 5
ansi_cur_bw() {
    printf '%s%sD' "$ANSI_CSI" "${1-}"
}

# Move the cursor backward by tab stops.
# Inputs: $1 - Optional tab-stop count.
#
# Output: Writes CSI Ps Z to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_cur_bw_tab 2
ansi_cur_bw_tab() {
    printf '%s%sZ' "$ANSI_CSI" "${1-}"
}

# Move the cursor down by rows.
# Inputs: $1 - Optional row count.
#
# Output: Writes CSI Ps B to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_cur_dn 3
ansi_cur_dn() {
    printf '%s%sB' "$ANSI_CSI" "${1-}"
}

# Move the cursor up by rows.
# Inputs: $1 - Optional row count.
#
# Output: Writes CSI Ps A to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_cur_up 3
ansi_cur_up() {
    printf '%s%sA' "$ANSI_CSI" "${1-}"
}

# Enable blinking cursor or slow blink text mode.
# Inputs: none.
#
# Output: Writes CSI 5 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_cur_blink
ansi_cur_blink() {
    printf '%s5m' "$ANSI_CSI"
}

# Enable rapid blink mode.
# Inputs: none.
#
# Output: Writes CSI 6 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_cur_blink_rapid
ansi_cur_blink_rapid() {
    printf '%s6m' "$ANSI_CSI"
}

# Disable blink mode.
# Inputs: none.
#
# Output: Writes CSI 25 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_cur_blink_off
ansi_cur_blink_off() {
    printf '%s25m' "$ANSI_CSI"
}

# Move the cursor to an absolute column.
# Inputs: $1 - Optional column number.
#
# Output: Writes CSI Ps G to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_cur_col 40
ansi_cur_col() {
    printf '%s%sG' "$ANSI_CSI" "${1-}"
}

# Move the cursor horizontally by columns.
# Inputs: $1 - Optional relative column count.
#
# Output: Writes CSI Ps a to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_cur_col_rel 4
ansi_cur_col_rel() {
    printf '%s%sa' "$ANSI_CSI" "${1-}"
}

# Hide the cursor.
# Inputs: none.
#
# Output: Writes CSI ? 25 l to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_cur_hide
ansi_cur_hide() {
    printf '%s?25l' "$ANSI_CSI"
}

# Show the cursor.
# Inputs: none.
#
# Output: Writes CSI ? 25 h to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_cur_show
ansi_cur_show() {
    printf '%s?25h' "$ANSI_CSI"
}

# Move the cursor to an absolute line.
# Inputs: $1 - Optional line number.
#
# Output: Writes CSI Ps d to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_cur_lf 12
ansi_cur_lf() {
    printf '%s%sd' "$ANSI_CSI" "${1-}"
}

# Move the cursor down by lines.
# Inputs: $1 - Optional relative line count.
#
# Output: Writes CSI Ps e to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_cur_lf_rel 2
ansi_cur_lf_rel() {
    printf '%s%se' "$ANSI_CSI" "${1-}"
}

# Move the cursor to the next line.
# Inputs: $1 - Optional line count.
#
# Output: Writes CSI Ps E to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_cur_nl 1
ansi_cur_nl() {
    printf '%s%sE' "$ANSI_CSI" "${1-}"
}

# Move the cursor to the previous line.
# Inputs: $1 - Optional line count.
#
# Output: Writes CSI Ps F to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_cur_prev_line 1
ansi_cur_prev_line() {
    printf '%s%sF' "$ANSI_CSI" "${1-}"
}

# Scroll the display down.
# Inputs: $1 - Optional row count.
#
# Output: Writes CSI Ps T to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_scr_down 3
ansi_scr_down() {
    printf '%s%sT' "$ANSI_CSI" "${1-}"
}

# Scroll the display up.
# Inputs: $1 - Optional row count.
#
# Output: Writes CSI Ps S to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_scr_up 3
ansi_scr_up() {
    printf '%s%sS' "$ANSI_CSI" "${1-}"
}

# Insert blank characters at the cursor.
# Inputs: $1 - Optional character count.
#
# Output: Writes CSI Ps @ to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_ins_chars 2
ansi_ins_chars() {
    printf '%s%s@' "$ANSI_CSI" "${1-}"
}

# Insert lines at the cursor.
# Inputs: $1 - Optional line count.
#
# Output: Writes CSI Ps L to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_ins_lines 2
ansi_ins_lines() {
    printf '%s%sL' "$ANSI_CSI" "${1-}"
}

# Delete characters at the cursor.
# Inputs: $1 - Optional character count.
#
# Output: Writes CSI Ps P to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_del_chars 2
ansi_del_chars() {
    printf '%s%sP' "$ANSI_CSI" "${1-}"
}

# Delete lines at the cursor.
# Inputs: $1 - Optional line count.
#
# Output: Writes CSI Ps M to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_del_lines 2
ansi_del_lines() {
    printf '%s%sM' "$ANSI_CSI" "${1-}"
}

# Erase part or all of the display.
# Inputs: $1 - Optional erase mode, such as 0, 1, or 2.
#
# Output: Writes CSI Ps J to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_erase_display 2
ansi_erase_display() {
    printf '%s%sJ' "$ANSI_CSI" "${1-}"
}

# Erase characters at the cursor.
# Inputs: $1 - Optional character count.
#
# Output: Writes CSI Ps X to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_erase_chars 10
ansi_erase_chars() {
    printf '%s%sX' "$ANSI_CSI" "${1-}"
}

# Erase part or all of the current line.
# Inputs: $1 - Optional erase mode, such as 0, 1, or 2.
#
# Output: Writes CSI Ps K to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_erase_lines 2
ansi_erase_lines() {
    printf '%s%sK' "$ANSI_CSI" "${1-}"
}

#### FORMAT ####

# Reset text attributes.
# Inputs: none.
#
# Output: Writes CSI 0 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fmt_reset
ansi_fmt_reset() {
    printf '%s0m' "$ANSI_CSI"
}

# Enable bold text.
# Inputs: none.
#
# Output: Writes CSI 1 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fmt_bold
ansi_fmt_bold() {
    printf '%s1m' "$ANSI_CSI"
}

# Disable bold or faint text.
# Inputs: none.
#
# Output: Writes CSI 22 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fmt_bold_off
ansi_fmt_bold_off() {
    printf '%s22m' "$ANSI_CSI"
}

# Enable italic text.
# Inputs: none.
#
# Output: Writes CSI 3 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fmt_italic
ansi_fmt_italic() {
    printf '%s3m' "$ANSI_CSI"
}

# Disable italic or fraktur text.
# Inputs: none.
#
# Output: Writes CSI 23 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fmt_italic_off
ansi_fmt_italic_off() {
    printf '%s23m' "$ANSI_CSI"
}

# Enable fraktur text where supported.
# Inputs: none.
#
# Output: Writes CSI 20 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fmt_fraktur
ansi_fmt_fraktur() {
    printf '%s20m' "$ANSI_CSI"
}

# Enable single underline.
# Inputs: none.
#
# Output: Writes CSI 4 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fmt_underline
ansi_fmt_underline() {
    printf '%s4m' "$ANSI_CSI"
}

# Enable double underline.
# Inputs: none.
#
# Output: Writes CSI 21 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fmt_underline2
ansi_fmt_underline2() {
    printf '%s21m' "$ANSI_CSI"
}

# Enable strikethrough text.
# Inputs: none.
#
# Output: Writes CSI 9 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fmt_strike
ansi_fmt_strike() {
    printf '%s9m' "$ANSI_CSI"
}

# Disable strikethrough text.
# Inputs: none.
#
# Output: Writes CSI 29 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fmt_strike_off
ansi_fmt_strike_off() {
    printf '%s29m' "$ANSI_CSI"
}

# Disable underline text.
# Inputs: none.
#
# Output: Writes CSI 24 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fmt_underline_off
ansi_fmt_underline_off() {
    printf '%s24m' "$ANSI_CSI"
}

# Enable faint text.
# Inputs: none.
#
# Output: Writes CSI 2 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fmt_faint
ansi_fmt_faint() {
    printf '%s2m' "$ANSI_CSI"
}

# Enable inverse video.
# Inputs: none.
#
# Output: Writes CSI 7 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fmt_inverse
ansi_fmt_inverse() {
    printf '%s7m' "$ANSI_CSI"
}

# Disable inverse video.
# Inputs: none.
#
# Output: Writes CSI 27 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fmt_inverse_off
ansi_fmt_inverse_off() {
    printf '%s27m' "$ANSI_CSI"
}

# Enable invisible text.
# Inputs: none.
#
# Output: Writes CSI 8 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fmt_invisible
ansi_fmt_invisible() {
    printf '%s8m' "$ANSI_CSI"
}

# Disable invisible text.
# Inputs: none.
#
# Output: Writes CSI 28 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fmt_visible
ansi_fmt_visible() {
    printf '%s28m' "$ANSI_CSI"
}

# Set the terminal icon name.
# Inputs: $1 - Icon name text; empty string clears it where supported.
#
# Output: Writes OSC 1 escape sequence to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fmt_icon "my-script"
ansi_fmt_icon() {
    printf '%s1;%s%s' "$ANSI_OSC" "${1-}" "$ANSI_ST"
}

# Set the terminal window title.
# Inputs: $1 - Title text; empty string clears it where supported.
#
# Output: Writes OSC 2 escape sequence to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fmt_title "Build log"
ansi_fmt_title() {
    printf '%s2;%s%s' "$ANSI_OSC" "${1-}" "$ANSI_ST"
}

#### FONTS ####

# Select an alternate terminal font.
# Inputs: $1 - Font number; defaults to 0.
#
# Output: Writes CSI 1N m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_font 3
ansi_font() {
    printf '%s1%sm' "$ANSI_CSI" "${1-0}"
}

# Reset the terminal font.
# Inputs: none.
#
# Output: Writes CSI 10 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_font_reset
ansi_font_reset() {
    printf '%s10m' "$ANSI_CSI"
}

#### COLORS ####

# Reset the foreground color.
# Inputs: none.
#
# Output: Writes CSI 39 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fg_reset
ansi_fg_reset() {
    printf '%s39m' "$ANSI_CSI"
}

# Set the foreground color by 256-color index.
# Inputs: $1 - Color index from the terminal palette.
#
# Output: Writes CSI 38;5;N m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fg 123
ansi_fg() {
    printf '%s38;5;%sm' "$ANSI_CSI" "$1"
}

# Set the foreground color by RGB components.
# Inputs:
#   $1 - Red component.
#   $2 - Green component.
#   $3 - Blue component.
#
# Output: Writes CSI 38;2;R;G;B m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fg_rgb 255 0 0
ansi_fg_rgb() {
    printf '%s38;2;%s;%s;%sm' "$ANSI_CSI" "$1" "$2" "$3"
}

# Set the foreground color to black.
# Inputs: none.
#
# Output: Writes CSI 30 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fg_black
ansi_fg_black() {
    printf '%s30m' "$ANSI_CSI"
}

# Set the foreground color to intense black.
# Inputs: none.
#
# Output: Writes CSI 90 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fg_black_i
ansi_fg_black_i() {
    printf '%s90m' "$ANSI_CSI"
}

# Set the foreground color to blue.
# Inputs: none.
#
# Output: Writes CSI 34 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fg_blue
ansi_fg_blue() {
    printf '%s34m' "$ANSI_CSI"
}

# Set the foreground color to intense blue.
# Inputs: none.
#
# Output: Writes CSI 94 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fg_blue_i
ansi_fg_blue_i() {
    printf '%s94m' "$ANSI_CSI"
}

# Set the foreground color to cyan.
# Inputs: none.
#
# Output: Writes CSI 36 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fg_cyan
ansi_fg_cyan() {
    printf '%s36m' "$ANSI_CSI"
}

# Set the foreground color to intense cyan.
# Inputs: none.
#
# Output: Writes CSI 96 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fg_cyan_i
ansi_fg_cyan_i() {
    printf '%s96m' "$ANSI_CSI"
}

# Set the foreground color to green.
# Inputs: none.
#
# Output: Writes CSI 32 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fg_green
ansi_fg_green() {
    printf '%s32m' "$ANSI_CSI"
}

# Set the foreground color to intense green.
# Inputs: none.
#
# Output: Writes CSI 92 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fg_green_i
ansi_fg_green_i() {
    printf '%s92m' "$ANSI_CSI"
}

# Set the foreground color to magenta.
# Inputs: none.
#
# Output: Writes CSI 35 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fg_magenta
ansi_fg_magenta() {
    printf '%s35m' "$ANSI_CSI"
}

# Set the foreground color to intense magenta.
# Inputs: none.
#
# Output: Writes CSI 95 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fg_magenta_i
ansi_fg_magenta_i() {
    printf '%s95m' "$ANSI_CSI"
}

# Set the foreground color to red.
# Inputs: none.
#
# Output: Writes CSI 31 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fg_red
ansi_fg_red() {
    printf '%s31m' "$ANSI_CSI"
}

# Set the foreground color to intense red.
# Inputs: none.
#
# Output: Writes CSI 91 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fg_red_i
ansi_fg_red_i() {
    printf '%s91m' "$ANSI_CSI"
}

# Set the foreground color to white.
# Inputs: none.
#
# Output: Writes CSI 37 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fg_white
ansi_fg_white() {
    printf '%s37m' "$ANSI_CSI"
}

# Set the foreground color to intense white.
# Inputs: none.
#
# Output: Writes CSI 97 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fg_white_i
ansi_fg_white_i() {
    printf '%s97m' "$ANSI_CSI"
}

# Set the foreground color to yellow.
# Inputs: none.
#
# Output: Writes CSI 33 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fg_yellow
ansi_fg_yellow() {
    printf '%s33m' "$ANSI_CSI"
}

# Set the foreground color to intense yellow.
# Inputs: none.
#
# Output: Writes CSI 93 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_fg_yellow_i
ansi_fg_yellow_i() {
    printf '%s93m' "$ANSI_CSI"
}

# ------------ #

# Reset the background color.
# Inputs: none.
#
# Output: Writes CSI 49 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_bg_reset
ansi_bg_reset() {
    printf '%s49m' "$ANSI_CSI"
}

# Set the background color by 256-color index.
# Inputs: $1 - Color index from the terminal palette.
#
# Output: Writes CSI 48;5;N m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_bg 45
ansi_bg() {
    printf '%s48;5;%sm' "$ANSI_CSI" "$1"
}

# Set the background color by RGB components.
# Inputs:
#   $1 - Red component.
#   $2 - Green component.
#   $3 - Blue component.
#
# Output: Writes CSI 48;2;R;G;B m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_bg_rgb 0 0 255
ansi_bg_rgb() {
    printf '%s48;2;%s;%s;%sm' "$ANSI_CSI" "$1" "$2" "$3"
}

# Set the background color to black.
# Inputs: none.
#
# Output: Writes CSI 40 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_bg_black
ansi_bg_black() {
    printf '%s40m' "$ANSI_CSI"
}

# Set the background color to intense black.
# Inputs: none.
#
# Output: Writes CSI 100 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_bg_black_i
ansi_bg_black_i() {
    printf '%s100m' "$ANSI_CSI"
}

# Set the background color to blue.
# Inputs: none.
#
# Output: Writes CSI 44 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_bg_blue
ansi_bg_blue() {
    printf '%s44m' "$ANSI_CSI"
}

# Set the background color to intense blue.
# Inputs: none.
#
# Output: Writes CSI 104 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_bg_blue_i
ansi_bg_blue_i() {
    printf '%s104m' "$ANSI_CSI"
}

# Set the background color to cyan.
# Inputs: none.
#
# Output: Writes CSI 46 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_bg_cyan
ansi_bg_cyan() {
    printf '%s46m' "$ANSI_CSI"
}

# Set the background color to intense cyan.
# Inputs: none.
#
# Output: Writes CSI 106 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_bg_cyan_i
ansi_bg_cyan_i() {
    printf '%s106m' "$ANSI_CSI"
}

# Set the background color to green.
# Inputs: none.
#
# Output: Writes CSI 42 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_bg_green
ansi_bg_green() {
    printf '%s42m' "$ANSI_CSI"
}

# Set the background color to intense green.
# Inputs: none.
#
# Output: Writes CSI 102 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_bg_green_i
ansi_bg_green_i() {
    printf '%s102m' "$ANSI_CSI"
}

# Set the background color to magenta.
# Inputs: none.
#
# Output: Writes CSI 45 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_bg_magenta
ansi_bg_magenta() {
    printf '%s45m' "$ANSI_CSI"
}

# Set the background color to intense magenta.
# Inputs: none.
#
# Output: Writes CSI 105 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_bg_magenta_i
ansi_bg_magenta_i() {
    printf '%s105m' "$ANSI_CSI"
}

# Set the background color to red.
# Inputs: none.
#
# Output: Writes CSI 41 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_bg_red
ansi_bg_red() {
    printf '%s41m' "$ANSI_CSI"
}

# Set the background color to intense red.
# Inputs: none.
#
# Output: Writes CSI 101 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_bg_red_i
ansi_bg_red_i() {
    printf '%s101m' "$ANSI_CSI"
}

# Set the background color to white.
# Inputs: none.
#
# Output: Writes CSI 47 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_bg_white
ansi_bg_white() {
    printf '%s47m' "$ANSI_CSI"
}

# Set the background color to intense white.
# Inputs: none.
#
# Output: Writes CSI 107 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_bg_white_i
ansi_bg_white_i() {
    printf '%s107m' "$ANSI_CSI"
}

# Set the background color to yellow.
# Inputs: none.
#
# Output: Writes CSI 43 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_bg_yellow
ansi_bg_yellow() {
    printf '%s43m' "$ANSI_CSI"
}

# Set the background color to intense yellow.
# Inputs: none.
#
# Output: Writes CSI 103 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_bg_yellow_i
ansi_bg_yellow_i() {
    printf '%s103m' "$ANSI_CSI"
}

#### IDEOGRAM ####

# Enable left-side ideogram underline where supported.
# Inputs: none.
#
# Output: Writes CSI 62 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_ig_left
ansi_ig_left() {
    printf '%s62m' "$ANSI_CSI"
}

# Enable double left-side ideogram underline where supported.
# Inputs: none.
#
# Output: Writes CSI 63 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_ig_left2
ansi_ig_left2() {
    printf '%s63m' "$ANSI_CSI"
}

# Enable right-side ideogram underline where supported.
# Inputs: none.
#
# Output: Writes CSI 60 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_ig_right
ansi_ig_right() {
    printf '%s60m' "$ANSI_CSI"
}

# Enable double right-side ideogram underline where supported.
# Inputs: none.
#
# Output: Writes CSI 61 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_ig_right2
ansi_ig_right2() {
    printf '%s61m' "$ANSI_CSI"
}

# Enable ideogram stress marking where supported.
# Inputs: none.
#
# Output: Writes CSI 64 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_ig_stress
ansi_ig_stress() {
    printf '%s64m' "$ANSI_CSI"
}

# Reset ideogram attributes.
# Inputs: none.
#
# Output: Writes CSI 65 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_ig_reset
ansi_ig_reset() {
    printf '%s65m' "$ANSI_CSI"
}

#### FRAMES ####

# Enable encircled text frame where supported.
# Inputs: none.
#
# Output: Writes CSI 52 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_frame_encircle
ansi_frame_encircle() {
    printf '%s52m' "$ANSI_CSI"
}

# Enable framed text where supported.
# Inputs: none.
#
# Output: Writes CSI 51 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_frame
ansi_frame() {
    printf '%s51m' "$ANSI_CSI"
}

# Reset framed or encircled text.
# Inputs: none.
#
# Output: Writes CSI 54 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_frame_reset
ansi_frame_reset() {
    printf '%s54m' "$ANSI_CSI"
}

# Enable overline text.
# Inputs: none.
#
# Output: Writes CSI 53 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_frame_overline
ansi_frame_overline() {
    printf '%s53m' "$ANSI_CSI"
}

# Disable overline text.
# Inputs: none.
#
# Output: Writes CSI 55 m to stdout.
#
# Returns: 0 unless printf fails.
#
# Example: ansi_frame_overline_off
ansi_frame_overline_off() {
    printf '%s55m' "$ANSI_CSI"
}


#### REPORT ####

# Test whether ANSI escape output is supported.
# Inputs:
#   None; ANSI_FORCE_SUPPORT bypasses detection when set.
#
# Output:
#   May send a terminal report query while probing support.
#
# Returns:
#   0 when ANSI support is detected or forced; 1 otherwise.
#
# Example:
#   if ansi_is_supported; then ansi_fg_green; fi
ansi_is_supported() {
    # Optionally override detection logic
    # to support post processors that interpret color codes _after_ output is generated.
    # Use environment variable "ANSI_FORCE_SUPPORT=<anything>" to enable the override.
    if [[ -n "${ANSI_FORCE_SUPPORT-}" ]]; then
        return 0
    fi

    if hash tput &> /dev/null; then
        if [[ "$(tput colors)" -lt 8 ]]; then
            return 1
        fi

        return 0
    fi

    # Query the console and see if we get ANSI codes back.
    # CSI 0 c == CSI c == Primary Device Attributes.
    # Idea:  CSI c
    # Response = CSI ? 6 [234] ; 2 2 c
    # The "22" means ANSI color, but terminals don't need to send that back.
    # If we get anything back, let's assume it works.
    ansi_report c "$ANSI_CSI?" c || return 1
    [[ -n "$ANSI_REPORT" ]]
}

# Query a terminal report and store the response.
# Inputs:
#   $1 - Query suffix sent after CSI.
#   $2 - Expected response prefix.
#   $3 - Expected response terminator.
#
# Output:
#   Sends the query through read -p and stores the body in ANSI_REPORT.
#
# Returns:
#   0 when the expected response is read; 1 on prefix mismatch or timeout.
#
# Example:
#   ansi_report 6n "$ANSI_CSI" R && printf '%s\n' "$ANSI_REPORT"
ansi_report() {
    local buff c report

    report=""

    # Note: read bypass piping, which lets this work:
    # ansi --report-window-chars | cut -d , -f 1
    read -p "$ANSI_CSI$1" -r -N "${#2}" -s -t 1 buff

    if [ "$buff" != "$2" ]; then
        return 1
    fi

    read -r -N "${#3}" -s -t 1 buff

    while [[ "$buff" != "$3" ]]; do
        report="$report${buff:0:1}"
        read -r -N 1 -s -t 1 c || exit 1
        buff="${buff:1}$c"
    done

    ANSI_REPORT=$report
}

# Report the cursor position.
# Inputs: none.
#
# Output: Writes ROW,COL to stdout.
#
# Returns: 0 when the terminal reports a position; 1 otherwise.
#
# Example: ansi_report_pos
ansi_report_pos() {
    ansi_report 6n "$ANSI_CSI" R || return 1
    printf '%s\n' "${ANSI_REPORT//;/,}"
}

# Report the terminal icon name.
# Inputs: none.
#
# Output: Writes the icon report with semicolons converted to commas.
#
# Returns: 0 when the terminal reports an icon name; 1 otherwise.
#
# Example: ansi_report_icon
ansi_report_icon() {
    ansi_report 20t "${ANSI_OSC}L" "$ANSI_ST" || return 1
    printf '%s\n' "${ANSI_REPORT//;/,}"
}

# Report the screen size in characters.
# Inputs: none.
#
# Output: Writes the reported size with semicolons converted to commas.
#
# Returns: 0 when the terminal reports screen character size; 1 otherwise.
#
# Example: ansi_report_screen_chars
ansi_report_screen_chars() {
    ansi_report 19t "${ANSI_CSI}9;" t || return 1
    printf '%s\n' "${ANSI_REPORT//;/,}"
}

# Report the terminal window title.
# Inputs: none.
#
# Output: Writes the title report with semicolons converted to commas.
#
# Returns: 0 when the terminal reports a title; 1 otherwise.
#
# Example: ansi_report_title
ansi_report_title() {
    ansi_report 21t "${ANSI_OSC}l" "$ANSI_ST" || return 1
    printf '%s\n' "${ANSI_REPORT//;/,}"
}

# Report the window size in characters.
# Inputs: none.
#
# Output: Writes ROWS,COLS to stdout when supported.
#
# Returns: 0 when the terminal reports window character size; 1 otherwise.
#
# Example: ansi_report_window_chars
ansi_report_window_chars() {
    ansi_report 18t "${ANSI_CSI}8;" t || return 1
    printf '%s\n' "${ANSI_REPORT//;/,}"
}

# Report the window size in pixels.
# Inputs: none.
#
# Output: Writes HEIGHT,WIDTH to stdout when supported.
#
# Returns: 0 when the terminal reports window pixel size; 1 otherwise.
#
# Example: ansi_report_window_pixels
ansi_report_window_pixels() {
    ansi_report 14t "${ANSI_CSI}4;" t || return 1
    printf '%s\n' "${ANSI_REPORT//;/,}"
}

# Report the window position.
# Inputs: none.
#
# Output: Writes X,Y to stdout when supported.
#
# Returns: 0 when the terminal reports window position; 1 otherwise.
#
# Example: ansi_report_window_pos
ansi_report_window_pos() {
    ansi_report 13t "${ANSI_CSI}3;" t || return 1
    printf '%s\n' "${ANSI_REPORT//;/,}"
}

# Report the terminal window state.
# Inputs: none.
#
# Output: Writes "open", "iconified", or "unknown (N)".
#
# Returns: 0 when the terminal reports state; 1 otherwise.
#
# Example: ansi_report_window_state
ansi_report_window_state() {
    ansi_report 11t "$ANSI_CSI" t || return 1
    case "$ANSI_REPORT" in
        1)
            printf 'open\n'
            ;;

        2)
            printf 'iconified\n'
            ;;

        *)
            printf 'unknown (%s)\n' "$ANSI_REPORT"
            ;;
    esac
}

# Print help for the ansi_ansi option wrapper.
# Inputs: none.
#
# Output: Writes usage text to stdout.
#
# Returns: 0 unless the here-document write fails.
#
# Example: ansi_help
ansi_help() {
    cat <<'EOF'
Usage: ansi_ansi [options] [text...]

Generate ANSI escape sequences directly or wrap text with style options.

Common options:
  --bold --italic --underline --strike --inverse
  --red --green --yellow --blue --magenta --cyan --white
  --bg-red --bg-green --bg-yellow --bg-blue --bg-magenta --bg-cyan --bg-white
  --rgb=R,G,B --bg-rgb=R,G,B --color=N --bg-color=N
  --position=ROW,COL --up=N --down=N --forward=N --backward=N
  --save-cursor --restore-cursor --hide-cursor --show-cursor
  --reset --bell -n --no-newline --no-restore

Example:
  ansi_ansi --bold --red "failed"
EOF
}

#### MAIN ####

# Emit ANSI controls and optionally wrap text with temporary styles.
# Inputs:
#   $@ - ansi_ansi options followed by optional text. Use "--" before text that
#   starts with a dash.
#
# Output:
#   Writes ANSI escape sequences, text, optional restore sequences, and a
#   trailing newline unless -n or --no-newline is passed.
#
# Returns:
#   0 on success; 1 when a requested terminal report is unsupported or fails.
#
# Example:
#   ansi_ansi --bold --red "failed"
ansi_ansi() {
    local addNewline b g m r readOptions restoreText restoreCursorPosition restoreCursorVisibility supported triggerRestore
    local m10 m22 m23 m24 m25 m27 m28 m29 m39 m49 m54 m55 m65

    addNewline=true
    m10=
    m22=
    m23=
    m24=
    m25=
    m27=
    m28=
    m29=
    m39=
    m49=
    m54=
    m55=
    m65=
    readOptions=true
    restoreCursorPosition=false
    restoreCursorVisibility=false
    restoreText=false
    supported=true
    triggerRestore=true

    if ! ansi_is_supported; then
        supported=false
    fi

    while $readOptions && [[ $# -gt 0 ]]; do
        case "$1" in
            --help | -h | -\?)
                ansi_help
                return 0
                ;;

            # Display Manipulation
            --insert-chars | --insert-char | --ich)
                $supported && ansi_ins_chars
                ;;

            --insert-chars=* | insert-char=* | --ich=*)
                $supported && ansi_ins_chars "${1#*=}"
                ;;

            --erase-display | --ed)
                $supported && ansi_erase_display
                ;;

            --erase-display=* | --ed=*)
                $supported && ansi_erase_display "${1#*=}"
                ;;

            --erase-line | --el)
                $supported && ansi_erase_lines
                ;;

            --erase-line=* | --el=*)
                $supported && ansi_erase_lines "${1#*=}"
                ;;

            --insert-lines | --insert-line | --il)
                $supported && ansi_ins_lines
                ;;

            --insert-lines=* | --insert-line=* | --il=*)
                $supported && ansi_ins_lines "${1#*=}"
                ;;

            --delete-lines | --delete-line | --dl)
                $supported && ansi_del_lines
                ;;

            --delete-lines=* | --delete-line=* | --dl=*)
                $supported && ansi_del_lines "${1#*=}"
                ;;

            --delete-chars | --delete-char | --dch)
                $supported && ansi_del_chars
                ;;

            --delete-chars=* | --delete-char=* | --dch=*)
                $supported && ansi_del_chars "${1#*=}"
                ;;

            --scroll-up | --su)
                $supported && ansi_scr_up
                ;;

            --scroll-up=* | --su=*)
                $supported && ansi_scr_up "${1#*=}"
                ;;

            --scroll-down | --sd)
                $supported && ansi_scr_down
                ;;

            --scroll-down=* | --sd=*)
                $supported && ansi_scr_down "${1#*=}"
                ;;

            --erase-chars | --erase-char | --ech)
                $supported && ansi_erase_chars
                ;;

            --erase-chars=* | --erase-char=* | --ech=*)
                $supported && ansi_erase_chars "${1#*=}"
                ;;

            --repeat | --rep)
                $supported && ansi_repeat
                ;;

            --repeat=* | --rep=N)
                $supported && ansi_repeat "${1#*=}"
                ;;

            # Cursor Positioning
            --up | --cuu)
                $supported && ansi_cur_up
                ;;

            --up=* | --cuu=*)
                $supported && ansi_cur_up "${1#*=}"
                ;;

            --down | --cud)
                $supported && ansi_cur_dn
                ;;

            --down=* | --cud=*)
                $supported && ansi_cur_dn "${1#*=}"
                ;;

            --forward | --cuf)
                $supported && ansi_cur_fw
                ;;

            --forward=* | --cuf=*)
                $supported && ansi_cur_fw "${1#*=}"
                ;;

            --backward | --cub)
                $supported && ansi_cur_bw
                ;;

            --backward=* | --cub=*)
                $supported && ansi_cur_bw "${1#*=}"
                ;;

            --next-line | --cnl)
                $supported && ansi_cur_nl
                ;;

            --next-line=* | --cnl=*)
                $supported && ansi_cur_nl "${1#*=}"
                ;;

            --previous-line | --prev-line | --cpl)
                $supported && ansi_cur_prev_line
                ;;

            --previous-line=* | --prev-line=* | --cpl=*)
                $supported && ansi_cur_prev_line "${1#*=}"
                ;;

            --column | --cha)
                $supported && ansi_cur_col
                ;;

            --column=* | --cha=*)
                $supported && ansi_cur_col "${1#*=}"
                ;;

            --position | --cup)
                $supported && ansi_cur_pos
                ;;

            --position=* | --cup=*)
                $supported && ansi_cur_pos "${1#*=}"
                ;;

            --tab-forward | --cht)
                $supported && ansi_cur_fw_tab
                ;;

            --tab-forward=* | --cht=*)
                $supported && ansi_cur_fw_tab "${1#*=}"
                ;;

            --tab-backward | --cbt)
                $supported && ansi_cur_bw_tab
                ;;

            --tab-backward=* | --cbt=*)
                $supported && ansi_cur_bw_tab "${1#*=}"
                ;;

            --column-relative | --hpr)
                $supported && ansi_cur_col_rel
                ;;

            --column-relative=* | --hpr=*)
                $supported && ansi_cur_col_rel "${1#*=}"
                ;;

            --line | --vpa)
                $supported && ansi_cur_lf
                ;;

            --line=* | --vpa=*)
                $supported && ansi_cur_lf "${1#*=}"
                ;;

            --line-relative | --vpr)
                $supported && ansi_cur_lf_rel
                ;;

            --line-relative=* | --vpr=*)
                $supported && ansi_cur_lf_rel "${1#*=}"
                ;;

            --save-cursor)
                $supported && ansi_cur_pos_save
                restoreCursorPosition=true
                ;;

            --restore-cursor)
                $supported && ansi_cur_restore
                ;;

            --hide-cursor)
                $supported && ansi_cur_hide
                restoreCursorVisibility=true
                ;;

            --show-cursor)
                $supported && ansi_cur_show
                ;;

            # Colors - Attributes
            --bold)
                $supported && ansi_fmt_bold
                restoreText=true
                m22="22;"
                ;;

            --faint)
                $supported && ansi_fmt_faint
                restoreText=true
                m22="22;"
                ;;

            --italic)
                $supported && ansi_fmt_italic
                restoreText=true
                m23="23;"
                ;;

            --underline)
                $supported && ansi_fmt_underline
                restoreText=true
                m24="24;"
                ;;

            --blink)
                $supported && ansi_cur_blink
                restoreText=true
                m25="25;"
                ;;

            --rapid-blink)
                $supported && ansi_cur_blink_rapid
                restoreText=true
                m25="25;"
                ;;

            --inverse)
                $supported && ansi_fmt_inverse
                restoreText=true
                m27="27;"
                ;;

            --invisible)
                $supported && ansi_fmt_invisible
                restoreText=true
                m28="28;"
                ;;

            --strike)
                $supported && ansi_fmt_strike
                restoreText=true
                m29="29;"
                ;;

            --font|--font=0)
                $supported && ansi_font_reset
                ;;

            --font=[123456789])
                $supported && ansi_font "${1#*=}"
                restoreText=true
                m10="10;"
                ;;

            --fraktur)
                $supported && ansi_fmt_fraktur
                restoreText=true
                m23="23;"
                ;;

            --double-underline)
                $supported && ansi_fmt_underline2
                restoreText=true
                m24="24;"
                ;;

            --normal)
                $supported && ansi_fmt_bold_off
                ;;

            --plain)
                $supported && ansi_fmt_italic_off
                ;;

            --no-underline)
                $supported && ansi_fmt_underline_off
                ;;

            --no-blink)
                $supported && ansi_cur_blink_off
                ;;

            --no-inverse)
                $supported && ansi_fmt_inverse_off
                ;;

            --visible)
                $supported && ansi_fmt_visible
                ;;

            --no-strike)
                $supported && ansi_fmt_strike_off
                ;;

            --frame)
                $supported && ansi_frame
                restoreText=true
                m54="54;"
                ;;

            --encircle)
                $supported && ansi_frame_encircle
                restoreText=true
                m54="54;"
                ;;

            --overline)
                $supported && ansi_frame_overline
                restoreText=true
                m55="55;"
                ;;

            --no-border)
                $supported && ansi_frame_reset
                ;;

            --no-overline)
                $supported && ansi_frame_overline_off
                ;;

            # Colors - Foreground
            --black)
                $supported && ansi_fg_black
                restoreText=true
                m39="39;"
                ;;

            --red)
                $supported && ansi_fg_red
                restoreText=true
                m39="39;"
                ;;

            --green)
                $supported && ansi_fg_green
                restoreText=true
                m39="39;"
                ;;

            --yellow)
                $supported && ansi_fg_yellow
                restoreText=true
                m39="39;"
                ;;

            --blue)
                $supported && ansi_fg_blue
                restoreText=true
                m39="39;"
                ;;

            --magenta)
                $supported && ansi_fg_magenta
                restoreText=true
                m39="39;"
                ;;

            --cyan)
                $supported && ansi_fg_cyan
                restoreText=true
                m39="39;"
                ;;

            --white)
                $supported && ansi_fg_white
                restoreText=true
                m39="39;"
                ;;

            --black-intense)
                $supported && ansi_fg_black_i
                restoreText=true
                m39="39;"
                ;;

            --red-intense)
                $supported && ansi_fg_red_i
                restoreText=true
                m39="39;"
                ;;

            --green-intense)
                $supported && ansi_fg_green_i
                restoreText=true
                m39="39;"
                ;;

            --yellow-intense)
                $supported && ansi_fg_yellow_i
                restoreText=true
                m39="39;"
                ;;

            --blue-intense)
                $supported && ansi_fg_blue_i
                restoreText=true
                m39="39;"
                ;;

            --magenta-intense)
                $supported && ansi_fg_magenta_i
                restoreText=true
                m39="39;"
                ;;

            --cyan-intense)
                $supported && ansi_fg_cyan_i
                restoreText=true
                m39="39;"
                ;;

            --white-intense)
                $supported && ansi_fg_white_i
                restoreText=true
                m39="39;"
                ;;

            --rgb=*,*,*)
                r=${1#*=}
                b=${r##*,}
                g=${r#*,}
                g=${g%,*}
                r=${r%%,*}
                $supported && ansi_fg_rgb "$r" "$g" "$b"
                restoreText=true
                m39="39;"
                ;;

            --color=*)
                $supported && ansi_fg "${1#*=}"
                restoreText=true
                m39="39;"
                ;;

            # Colors - Background
            --bg-black)
                $supported && ansi_bg_black
                restoreText=true
                m49="49;"
                ;;

            --bg-red)
                $supported && ansi_bg_red
                restoreText=true
                m49="49;"
                ;;

            --bg-green)
                $supported && ansi_bg_green
                restoreText=true
                m49="49;"
                ;;

            --bg-yellow)
                $supported && ansi_bg_yellow
                restoreText=true
                m49="49;"
                ;;

            --bg-blue)
                $supported && ansi_bg_blue
                restoreText=true
                m49="49;"
                ;;

            --bg-magenta)
                $supported && ansi_bg_magenta
                restoreText=true
                m49="49;"
                ;;

            --bg-cyan)
                $supported && ansi_bg_cyan
                restoreText=true
                m49="49;"
                ;;

            --bg-white)
                $supported && ansi_bg_white
                restoreText=true
                m49="49;"
                ;;

            --bg-black-intense)
                $supported && ansi_bg_black_i
                restoreText=true
                m49="49;"
                ;;

            --bg-red-intense)
                $supported && ansi_bg_red_i
                restoreText=true
                m49="49;"
                ;;

            --bg-green-intense)
                $supported && ansi_bg_green_i
                restoreText=true
                m49="49;"
                ;;

            --bg-yellow-intense)
                $supported && ansi_bg_yellow_i
                restoreText=true
                m49="49;"
                ;;

            --bg-blue-intense)
                $supported && ansi_bg_blue_i
                restoreText=true
                m49="49;"
                ;;

            --bg-magenta-intense)
                $supported && ansi_bg_magenta_i
                restoreText=true
                m49="49;"
                ;;

            --bg-cyan-intense)
                $supported && ansi_bg_cyan_i
                restoreText=true
                m49="49;"
                ;;

            --bg-white-intense)
                $supported && ansi_bg_white_i
                restoreText=true
                m49="49;"
                ;;

            --bg-rgb=*,*,*)
                r=${1#*=}
                b=${r##*,}
                g=${r#*,}
                g=${g%,*}
                r=${r%%,*}
                $supported && ansi_bg_rgb "$r" "$g" "$b"
                restoreText=true
                m49="49;"
                ;;

            --bg-color=*)
                $supported && ansi_bg "${1#*=}"
                restoreText=true
                m49="49;"
                ;;

            # Colors - Reset
            --reset-foreground)
                $supported && ansi_fg_reset
                ;;

            --reset-background)
                $supported && ansi_bg_reset
                ;;

            --reset-color)
                $supported && ansi_fg_reset
                ;;

            --reset-font)
                $supported && ansi_font_reset
                ;;

            # Reporting
            --report-position)
                $supported || return 1
                ansi_report_pos || return $?
                ;;

            --report-window-state)
                $supported || return 1
                ansi_report_window_state || return $?
                ;;

            --report-window-position)
                $supported || return 1
                ansi_report_window_pos || return $?
                ;;

            --report-window-pixels)
                $supported || return 1
                ansi_report_window_pixels || return $?
                ;;

            --report-window-chars)
                $supported || return 1
                ansi_report_window_chars || return $?
                ;;

            --report-screen-chars)
                $supported || return 1
                ansi_report_screen_chars || return $?
                ;;

            --report-icon)
                $supported || return 1
                ansi_report_icon || return $?
                ;;

            --report-title)
                $supported || return 1
                ansi_report_title || return $?
                ;;

            --ideogram-right)
                $supported && ansi_ig_right
                restoreText=true
                m65="65;"
                ;;

            --ideogram-right-double)
                $supported && ansi_ig_right2
                restoreText=true
                m65="65;"
                ;;

            --ideogram-left)
                $supported && ansi_ig_left
                restoreText=true
                m65="65;"
                ;;

            --ideogram-left-double)
                $supported && ansi_ig_left2
                restoreText=true
                m65="65;"
                ;;

            --ideogram-stress)
                $supported && ansi_ig_stress
                restoreText=true
                m65="65;"
                ;;

            --reset-ideogram)
                $supported && ansi_ig_reset
                ;;

            # Miscellaneous
            --icon)
                $supported && ansi_fmt_icon ""
                ;;

            --icon=*)
                $supported && ansi_fmt_icon "${1#*=}"
                ;;

            --title)
                $supported && ansi_fmt_title ""
                ;;

            --title=*)
                $supported && ansi_fmt_title "${1#*=}"
                ;;

            --no-restore)
                triggerRestore=false
                ;;

            -n | --no-newline)
                addNewline=false
                ;;

            --bell)
                ansi_bell
                ;;

            --reset)
                $supported || return 0
                ansi_reset
                ;;

            --)
                readOptions=false
                shift
                ;;

            *)
                readOptions=false
                ;;
        esac

        if $readOptions; then
            shift
        fi
    done

    printf '%s' "${1-}"

    if [[ "$#" -gt 1 ]]; then
        shift || :
        printf "${IFS:0:1}%s" "${@}"
    fi

    if $supported && $triggerRestore; then
        if $restoreCursorPosition; then
            ansi_cur_restore
        fi

        if $restoreCursorVisibility; then
            ansi_cur_show
        fi

        if $restoreText; then
            m="$m10$m22$m23$m24$m25$m27$m28$m29$m39$m49$m54$m55$m65"
            printf '%s%sm' "$ANSI_CSI" "${m%;}"
        fi
    fi

    if $addNewline; then
        printf '\n'
    fi
}


# Run if not sourced
if [[ "$0" == "${BASH_SOURCE[0]}" ]]; then
    ansi_ansi "$@" || exit $?
fi
