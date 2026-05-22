# Shell scripting library

Bash functions for common scripting tasks. Function names use snake_case:

- Module functions use `module_function`, for example `str_len`.
- Nested groups join each segment with an underscore, for example `os_path_ext` and `ansi_cur_pos_save`.
- Internal helper functions start with `_` and are not part of the public API.

The library targets Bash 4.3 or newer.

## Loading

Set `SHLIB_ROOT` to the `lib` directory, then source one module or the whole library:

```bash
export SHLIB_ROOT="/path/to/shlib/lib"

source "$SHLIB_ROOT/str.sh"  # one module
source "$SHLIB_ROOT/lib.sh"  # all modules
```

Some modules source dependencies through `SHLIB_ROOT`, so set it before loading modules directly.

## Testing

Run the test suite from the repository root:

```bash
bash tests/run.sh
```

Run all local quality checks:

```bash
scripts/check.sh
```

`scripts/check.sh` runs Bash syntax checks, the test suite, and `shellcheck -x` when ShellCheck is installed. Set `SHLIB_REQUIRE_SHELLCHECK=1` to fail when ShellCheck is missing.

## Examples

Functions that print values can be captured with command substitution:

```bash
length=$(str_len "abc")
path=$(os_path "/foo//bar/./w")
```

Use predicates in `if` statements. They return status `0` for true and non-zero for false:

```bash
if str_is_alpha "$name"; then
    log_msg "name contains only letters"
fi
```

Use the higher-level ANSI wrapper when you need a styled message:

```bash
ansi_ansi --bold --red "failed"
ansi_ansi --green "ok"
```

Use individual ANSI functions when you need manual control:

```bash
ansi_fg_blue
printf 'blue text\n'
ansi_fg_reset
```

Use math filters in pipelines:

```bash
math_eval "$PI/2" | math_sin | math_int
```

Parse command-line options into an associative array:

```bash
declare -a spec=()
declare -A opts=()
declare -a positionals=()

args_spec_add spec verbose flag v verbose false "Print debug output"
args_spec_add spec name string n name guest "Name to print"

if ! args_parse spec opts positionals "$@"; then
    args_usage spec "${0##*/}" "Example command."
    exit 2
fi
```

## Function Reference

### `str.sh`

| Function | Use case |
| --- | --- |
| `str_len VALUE` | Print the character count for `VALUE`, for example validating a minimum length. |
| `str_format FORMAT INPUT [VAR|-]` | Format one value with `printf`; pass `VAR` to write the result into a variable. |
| `str_join DELIM FIRST [REST...]` | Join arguments with `DELIM`, for example building a comma-separated list. |
| `str_replace STRING PATTERN REPLACEMENT` | Replace every literal `PATTERN` in `STRING`. |
| `str_trim STRING` | Remove leading and trailing whitespace from input text. |
| `str_strip_a PATTERN VALUE...` | Remove all occurrences of `PATTERN` from each value. |
| `str_strip_f PATTERN VALUE...` | Remove the first occurrence of `PATTERN` from each value. |
| `str_strip_l PATTERN VALUE...` | Remove a matching prefix pattern from each value. |
| `str_strip_r PATTERN VALUE...` | Remove a matching suffix pattern from each value. |
| `str_split DELIM STRING` | Split `STRING` on `DELIM` and print one item per line. |
| `str_url_encode VALUE` | Percent-encode text before placing it in a URL. |
| `str_url_decode VALUE` | Decode percent-encoded URL text. |
| `str_to_lower VALUE` | Normalize text to lowercase before comparison. |
| `str_to_upper VALUE` | Normalize text to uppercase before display or comparison. |
| `str_contains NEEDLE VALUE...` | Test whether the combined input contains `NEEDLE`. |
| `str_starts_with NEEDLE VALUE...` | Test whether the combined input starts with `NEEDLE`. |
| `str_ends_with NEEDLE VALUE...` | Test whether the combined input ends with `NEEDLE`. |
| `str_is_match VALUE PATTERN` | Test that `VALUE` does not match a shell pattern; used by the type predicates. |
| `str_is_digit VALUE` | Test that `VALUE` contains only digits. |
| `str_is_alpha VALUE` | Test that `VALUE` contains only ASCII letters. |
| `str_is_alnum VALUE` | Test that `VALUE` contains only ASCII letters and digits. |

### `arr.sh`

| Function | Use case |
| --- | --- |
| `arr_print ARRAY_NAME` | Print each element of a named Bash array on its own line. |
| `arr_append ARRAY_NAME VALUE...` | Append one or more values to a named Bash array. |
| `arr_size ARRAY_NAME` | Print the number of elements in a named Bash array. |
| `arr_reverse VALUE...` | Print arguments in reverse order. |
| `arr_uniq VALUE...` | Print unique non-empty arguments. |
| `arr_rand_elem VALUE...` | Print one random argument, for example choosing a random mirror. |

### `args.sh`

The argument parser stores option definitions in an indexed array and parsed values in an associative array.

| Function | Use case |
| --- | --- |
| `args_spec_add SPEC_ARRAY NAME TYPE SHORT LONG DEFAULT HELP` | Add an option definition. `TYPE` must be `flag`, `string`, or `int`. |
| `args_parse SPEC_ARRAY OPTS_ASSOC POSITIONALS_ARRAY ARG...` | Parse options and positional arguments into named arrays. |
| `args_usage SPEC_ARRAY COMMAND SUMMARY` | Print usage text from an option spec. |

Supported option forms are `--name value`, `--name=value`, `--no-name` for flags, and single-character short options such as `-v`.
Parse errors return status `2` and print a message to stderr.

### `assert.sh`

| Function | Use case |
| --- | --- |
| `assert_argc ACTUAL EXPECTED [MESSAGE]` | Exit with usage text when a command receives the wrong number of arguments. |
| `assert_argc_ge ACTUAL EXPECTED [MESSAGE]` | Exit with usage text when a command receives too few arguments. |
| `assert_args COUNT MESSAGE` | Exit with usage text when no arguments were provided. |
| `assert_pwd DIR...` | Require the current directory name to match one of the allowed names. |
| `test_var_defined NAME` | Test whether a variable is defined. |
| `assert_var_defined NAME` | Exit unless a variable is defined. |
| `test_var_set NAME` | Test whether a variable is defined and non-empty. |
| `assert_var_set NAME` | Exit unless a variable is defined and non-empty. |
| `test_fn_defined NAME` | Test whether a shell function is defined. |
| `assert_fn_defined NAME` | Exit unless a shell function is defined. |
| `test_all TEST ARG...` | Run `TEST` against every argument and return true only if all pass. |
| `test_any TEST ARG...` | Run `TEST` against every argument and return true if any pass. |
| `assert_pass COMMAND [ARG...]` | Exit unless `COMMAND` returns success. |
| `assert_that MESSAGE COMMAND [ARG...]` | Exit with `MESSAGE` unless `COMMAND` returns success. |
| `test_installed COMMAND` | Test whether a command is available in `PATH`. |
| `assert_installed COMMAND` | Exit unless a command is available in `PATH`. |

### `cmd.sh`

| Function | Use case |
| --- | --- |
| `cmd_exists COMMAND` | Test whether a command is available in `PATH`. |
| `cmd_require COMMAND...` | Print missing commands and return failure if any are unavailable. |
| `cmd_capture VAR COMMAND [ARG...]` | Run a command and store its stdout in `VAR`. |
| `cmd_retry ATTEMPTS DELAY COMMAND [ARG...]` | Retry a command until it succeeds or attempts are exhausted. |
| `cmd_timeout SECONDS COMMAND [ARG...]` | Run a command through `timeout`; return `127` when `timeout` is unavailable. |

### `config.sh`

The config module loads simple `KEY=VALUE` files into associative arrays. Keys must match `[A-Za-z_][A-Za-z0-9_]*`.
Malformed lines and invalid keys return status `2`.

| Function | Use case |
| --- | --- |
| `config_load FILE ASSOC_ARRAY` | Load a config file into an associative array. |
| `config_get ASSOC_ARRAY KEY [DEFAULT]` | Print a config value or an optional default. |
| `config_set ASSOC_ARRAY KEY VALUE` | Set a config value in an associative array. |

### `env.sh`

| Function | Use case |
| --- | --- |
| `env_defined NAME` | Test whether a variable is defined. |
| `env_set NAME` | Test whether a variable is defined and non-empty. |
| `env_require NAME...` | Print missing variables and return failure if any are unset or empty. |
| `env_default NAME VALUE` | Set and export `NAME=VALUE` when `NAME` is unset or empty. |
| `env_bool NAME` | Treat `1`, `true`, `yes`, `y`, and `on` as true values. |
| `env_load_dotenv FILE` | Load simple `KEY=VALUE` lines from a dotenv file. |

### `fs.sh`

| Function | Use case |
| --- | --- |
| `fs_exists PATH` | Test whether a path exists. |
| `fs_is_empty PATH` | Test whether a file is empty or a directory has no entries. |
| `fs_mkdirp PATH...` | Create directories with `mkdir -p`. |
| `fs_tempdir [PREFIX]` | Create a temporary directory and print its path. |
| `fs_readlink PATH` | Print a canonical path using `realpath` or `readlink -f`. |
| `fs_basename PATH` | Print the final path component. |
| `fs_dirname PATH` | Print the parent path component. |
| `fs_rm_empty_dir PATH` | Remove an empty directory. |

### `io.sh`

| Function | Use case |
| --- | --- |
| `io_is_dir PATH...` | Test that every path is a directory. |
| `io_is_dev PATH...` | Test that every path is a block device. |
| `io_is_file PATH...` | Test that every path is a regular file. |
| `io_readline [--delim CHAR] [--fd FD] [--] VAR` | Read one record into `VAR`, including the final record when the stream has no trailing delimiter. |
| `io_readlines [--delim CHAR] [--fd FD] [--] ARRAY` | Read records into a named Bash array. |

Example:

```bash
while io_readline line; do
    printf '[%s]\n' "$line"
done < input.txt
```

### `kv.sh`

The key/value module reads and writes plain `KEY=VALUE` files. Keys must match `[A-Za-z_][A-Za-z0-9_]*`.

| Function | Use case |
| --- | --- |
| `kv_get KEY FILE` | Print the value for `KEY`. |
| `kv_set KEY VALUE FILE` | Add or update `KEY=VALUE` in `FILE`. |
| `kv_has KEY FILE` | Test whether `KEY` exists in `FILE`. |
| `kv_keys FILE` | Print valid keys from `FILE`. |

### `log.sh`

| Function | Use case |
| --- | --- |
| `log_exec COMMAND [ARG...]` | Print the command, then run it. |
| `log_dbg MESSAGE` | Print a debug message when `SHLIB_LOG_DEBUG=true`. |
| `log_suc MESSAGE` | Print a success message. |
| `log_msg MESSAGE` | Print an informational message. |
| `log_wrn MESSAGE` | Print a warning message. |
| `log_err MESSAGE` | Print an error message. |
| `log_log LEVEL COLOR MESSAGE` | Print a custom log line with an explicit level and ANSI color escape. |
| `log_stacktrace` | Print the current Bash call stack while handling an error. |

### `math.sh`

| Function | Use case |
| --- | --- |
| `math_int [VALUE]` | Print the integer part of a decimal value. |
| `math_frac [VALUE]` | Print the fractional part of a decimal value. |
| `math_compute EXPR [SCALE]` | Evaluate a `bc` expression with the library function definitions loaded. |
| `math_cond EXPR [SCALE]` | Use a numeric expression as a shell condition. |
| `math_eval EXPR [SCALE]` | Evaluate an expression and return failure if no result is produced. |
| `math_sin [VALUE]` | Calculate sine for a radian value. |
| `math_cos [VALUE]` | Calculate cosine for a radian value. |
| `math_tan [VALUE]` | Calculate tangent for a radian value. |
| `math_cotan [VALUE]` | Calculate cotangent for a radian value. |
| `math_sec [VALUE]` | Calculate secant for a radian value. |
| `math_cosec [VALUE]` | Calculate cosecant for a radian value. |
| `math_csc [VALUE]` | Alias-style cosecant helper for scripts that use `csc`. |
| `math_asin [VALUE]` | Calculate arcsine. |
| `math_acos [VALUE]` | Calculate arccosine. |
| `math_atan [VALUE]` | Calculate arctangent. |
| `math_arccot [VALUE]` | Calculate arccotangent. |
| `math_arcsin [VALUE]` | Alias-style arcsine helper. |
| `math_arccos [VALUE]` | Alias-style arccosine helper. |
| `math_arctan [VALUE]` | Alias-style arctangent helper. |
| `math_ln [VALUE]` | Calculate the natural logarithm. |
| `math_log10 [VALUE]` | Calculate the base-10 logarithm. |
| `math_log [VALUE]` | Alias-style base-10 logarithm helper. |
| `math_exp [VALUE]` | Calculate `e` raised to `VALUE`. |
| `math_pow BASE EXP [SCALE]` | Raise `BASE` to `EXP`. |
| `math_deg [VALUE]` | Convert radians to degrees. |
| `math_ndeg [VALUE]` | Convert radians to normalized degrees in the `0..360` range. |
| `math_rad [VALUE]` | Convert degrees to radians. |
| `math_abs [VALUE]` | Calculate absolute value. |
| `math_hypot A B [SCALE]` | Calculate `sqrt(A^2 + B^2)`. |
| `math_round VALUE [PLACES]` | Round a decimal value to a number of places. |

When no value is passed, many math helpers prompt for input. This is useful for interactive shell sessions; scripts should pass arguments or pipe input.

### `net.sh`

| Function | Use case |
| --- | --- |
| `net_is_ipv4 VALUE` | Validate an IPv4 address before writing network config. |
| `net_is_fqdn VALUE` | Validate a fully qualified domain name. |
| `net_is_ipv4_netmask VALUE` | Validate a dotted IPv4 netmask such as `255.255.255.0`. |
| `net_is_ipv4_cidr VALUE` | Validate a CIDR prefix length from `0` to `32`. |
| `net_is_ipv4_subnet VALUE` | Validate an IPv4 subnet in `address/prefix` form. |

### `os.sh`

| Function | Use case |
| --- | --- |
| `os_path_abs PATH` | Print a normalized absolute path. |
| `os_path_file PATH` | Print the final path component. |
| `os_path_file_noext PATH` | Print the final path component without its last extension. |
| `os_path_ext PATH` | Print the last file extension. |
| `os_path_ext_full PATH` | Print everything after the first dot in the file name. |
| `os_path_par PATH` | Print the normalized parent directory. |
| `os_path PATH` | Normalize repeated slashes in a path. |

### `output.sh`

The output module prints plain text formats for command-line tools. `output_table` expects headers in an indexed array and rows as tab-separated strings.

| Function | Use case |
| --- | --- |
| `output_kv KEY VALUE` | Print one `KEY=VALUE` line. |
| `output_list VALUE...` | Print one value per line. |
| `output_table HEADER_ARRAY ROWS_ARRAY` | Print an aligned text table. |

### `prompt.sh`

The prompt module reads interactive input from `/dev/tty`. Set `SHLIB_PROMPT_TTY` to another readable path when testing.

| Function | Use case |
| --- | --- |
| `prompt_confirm QUESTION [yes|no|required]` | Ask a yes/no question with an optional default mode. |
| `prompt_input VAR PROMPT [DEFAULT]` | Read one line into `VAR`, using `DEFAULT` when the reply is empty. |
| `prompt_select VAR PROMPT OPTION...` | Show numbered options and write the selected value to `VAR`. |

### `semver.sh`

The semantic version module supports `MAJOR.MINOR.PATCH` versions.

| Function | Use case |
| --- | --- |
| `semver_parse VERSION` | Print `MAJOR MINOR PATCH` as normalized integers. |
| `semver_cmp A B` | Print `-1`, `0`, or `1` for version comparison. |
| `semver_eq A B` | Test whether two versions are equal. |
| `semver_lt A B` | Test whether `A` is less than `B`. |
| `semver_le A B` | Test whether `A` is less than or equal to `B`. |
| `semver_gt A B` | Test whether `A` is greater than `B`. |
| `semver_ge A B` | Test whether `A` is greater than or equal to `B`. |

### `std.sh`

| Function | Use case |
| --- | --- |
| `std_usage MESSAGE` | Print a usage error for the current script and exit. |
| `std_fat MESSAGE` | Print a fatal error and exit. |
| `std_ask QUESTION [Y|N]` | Ask an interactive yes/no question with an optional default. |
| `std_confirm COMMAND [ARG...]` | Run a command, then wait for a key press. |
| `std_beep [FREQ] [DURATION]` | Play a short PulseAudio sine tone. |

### `test.sh`

The test module provides reusable assertions for scripts that want the same lightweight test harness used by this repository.

| Function | Use case |
| --- | --- |
| `test_assert_eq EXPECTED ACTUAL` | Fail when two strings differ. |
| `test_assert_ne UNEXPECTED ACTUAL` | Fail when two strings are equal. |
| `test_assert_contains HAYSTACK NEEDLE` | Fail when `HAYSTACK` does not contain `NEEDLE`. |
| `test_assert_match VALUE REGEX` | Fail when `VALUE` does not match a Bash regex. |
| `test_assert_status STATUS COMMAND [ARG...]` | Fail when a command returns a different status. |
| `test_assert_success COMMAND [ARG...]` | Fail when a command returns non-zero. |
| `test_assert_failure COMMAND [ARG...]` | Fail when a command returns zero. |
| `test_assert_command_output EXPECTED COMMAND [ARG...]` | Fail when command stdout differs from `EXPECTED`. |
| `test_capture_subshell COMMAND [ARG...]` | Capture command output and status in `SHLIB_CAPTURE_OUTPUT` and `SHLIB_CAPTURE_STATUS`. |
| `test_assert_subshell_status STATUS SCRIPT` | Run a Bash script string and assert its exit status. |
| `test_run NAME FUNCTION` | Run one test function and print an `ok` or `not ok` line. |
| `test_finish` | Print the test summary and return failure if any test failed. |

### `time.sh`

| Function | Use case |
| --- | --- |
| `time_now` | Print the current Unix timestamp. |
| `date_now` | Print the current ISO date. |

### `url.sh`

| Function | Use case |
| --- | --- |
| `url_encode VALUE` | Percent-encode text for URL components. |
| `url_decode VALUE` | Decode percent-encoded URL text. |
| `url_query_get KEY QUERY` | Print the decoded value for `KEY` in a query string. |
| `url_query_set KEY VALUE QUERY` | Add or replace `KEY=VALUE` in a query string. |

`str_url_encode` and `str_url_decode` remain available as string-module wrappers.

### `ansi.sh`

The ANSI module prints escape sequences. Use low-level functions for precise control and `ansi_ansi` for option-based formatting.

#### ANSI: core

| Function | Use case |
| --- | --- |
| `ansi_bell` | Emit the terminal bell. |
| `ansi_repeat [N]` | Repeat the previous printable character `N` times. |
| `ansi_reset` | Reset formatting, font, display, cursor position, and cursor visibility. |
| `ansi_is_supported` | Test whether the current terminal appears to support ANSI sequences. |
| `ansi_help` | Print help for the `ansi_ansi` option wrapper. |
| `ansi_ansi [OPTIONS] [TEXT...]` | Format text or emit ANSI controls through command-line style options. |

#### ANSI: cursor and scrolling

| Function | Use case |
| --- | --- |
| `ansi_cur_restore` | Restore a saved cursor position. |
| `ansi_cur_pos [ROW,COL]` | Move the cursor to a row and column. |
| `ansi_cur_pos_save` | Save the current cursor position. |
| `ansi_cur_fw [N]` | Move the cursor forward. |
| `ansi_cur_fw_tab [N]` | Move the cursor forward by tab stops. |
| `ansi_cur_bw [N]` | Move the cursor backward. |
| `ansi_cur_bw_tab [N]` | Move the cursor backward by tab stops. |
| `ansi_cur_dn [N]` | Move the cursor down. |
| `ansi_cur_up [N]` | Move the cursor up. |
| `ansi_cur_blink` | Enable blinking cursor style where supported. |
| `ansi_cur_blink_rapid` | Enable rapid blinking cursor style where supported. |
| `ansi_cur_blink_off` | Disable blinking cursor style. |
| `ansi_cur_col [N]` | Move the cursor to column `N`. |
| `ansi_cur_col_rel [N]` | Move the cursor horizontally by `N` columns. |
| `ansi_cur_hide` | Hide the cursor during a redraw. |
| `ansi_cur_show` | Show the cursor after a redraw. |
| `ansi_cur_lf [N]` | Move the cursor to line `N`. |
| `ansi_cur_lf_rel [N]` | Move the cursor vertically by `N` lines. |
| `ansi_cur_nl [N]` | Move to the next line. |
| `ansi_cur_prev_line [N]` | Move to the previous line. |
| `ansi_scr_down [N]` | Scroll the screen down. |
| `ansi_scr_up [N]` | Scroll the screen up. |

#### ANSI: insert, delete, and erase

| Function | Use case |
| --- | --- |
| `ansi_ins_chars [N]` | Insert blank characters at the cursor. |
| `ansi_ins_lines [N]` | Insert blank lines at the cursor. |
| `ansi_del_chars [N]` | Delete characters at the cursor. |
| `ansi_del_lines [N]` | Delete lines at the cursor. |
| `ansi_erase_display [MODE]` | Erase part or all of the display. |
| `ansi_erase_chars [N]` | Erase characters at the cursor without moving it. |
| `ansi_erase_lines [MODE]` | Erase part or all of the current line. |

#### ANSI: text style and font

| Function | Use case |
| --- | --- |
| `ansi_fmt_reset` | Reset text style attributes. |
| `ansi_fmt_bold` | Start bold text. |
| `ansi_fmt_bold_off` | End bold or faint text. |
| `ansi_fmt_italic` | Start italic text. |
| `ansi_fmt_italic_off` | End italic or fraktur text. |
| `ansi_fmt_fraktur` | Start fraktur text where supported. |
| `ansi_fmt_underline` | Start underlined text. |
| `ansi_fmt_underline2` | Start double-underlined text. |
| `ansi_fmt_strike` | Start strikethrough text. |
| `ansi_fmt_strike_off` | End strikethrough text. |
| `ansi_fmt_underline_off` | End underlined text. |
| `ansi_fmt_faint` | Start faint text. |
| `ansi_fmt_inverse` | Start inverse colors. |
| `ansi_fmt_inverse_off` | End inverse colors. |
| `ansi_fmt_invisible` | Hide text while preserving layout. |
| `ansi_fmt_visible` | End hidden text. |
| `ansi_fmt_icon TITLE` | Set the terminal icon title. |
| `ansi_fmt_title TITLE` | Set the terminal window title. |
| `ansi_font [N]` | Select an alternate terminal font. |
| `ansi_font_reset` | Reset the terminal font. |

#### ANSI: foreground colors

| Function | Use case |
| --- | --- |
| `ansi_fg_reset` | Reset the foreground color. |
| `ansi_fg N` | Set a 256-color foreground by index. |
| `ansi_fg_rgb R G B` | Set a 24-bit foreground color. |
| `ansi_fg_black` | Start black foreground text. |
| `ansi_fg_black_i` | Start intense black foreground text. |
| `ansi_fg_blue` | Start blue foreground text. |
| `ansi_fg_blue_i` | Start intense blue foreground text. |
| `ansi_fg_cyan` | Start cyan foreground text. |
| `ansi_fg_cyan_i` | Start intense cyan foreground text. |
| `ansi_fg_green` | Start green foreground text. |
| `ansi_fg_green_i` | Start intense green foreground text. |
| `ansi_fg_magenta` | Start magenta foreground text. |
| `ansi_fg_magenta_i` | Start intense magenta foreground text. |
| `ansi_fg_red` | Start red foreground text. |
| `ansi_fg_red_i` | Start intense red foreground text. |
| `ansi_fg_white` | Start white foreground text. |
| `ansi_fg_white_i` | Start intense white foreground text. |
| `ansi_fg_yellow` | Start yellow foreground text. |
| `ansi_fg_yellow_i` | Start intense yellow foreground text. |

#### ANSI: background colors

| Function | Use case |
| --- | --- |
| `ansi_bg_reset` | Reset the background color. |
| `ansi_bg N` | Set a 256-color background by index. |
| `ansi_bg_rgb R G B` | Set a 24-bit background color. |
| `ansi_bg_black` | Start black background text. |
| `ansi_bg_black_i` | Start intense black background text. |
| `ansi_bg_blue` | Start blue background text. |
| `ansi_bg_blue_i` | Start intense blue background text. |
| `ansi_bg_cyan` | Start cyan background text. |
| `ansi_bg_cyan_i` | Start intense cyan background text. |
| `ansi_bg_green` | Start green background text. |
| `ansi_bg_green_i` | Start intense green background text. |
| `ansi_bg_magenta` | Start magenta background text. |
| `ansi_bg_magenta_i` | Start intense magenta background text. |
| `ansi_bg_red` | Start red background text. |
| `ansi_bg_red_i` | Start intense red background text. |
| `ansi_bg_white` | Start white background text. |
| `ansi_bg_white_i` | Start intense white background text. |
| `ansi_bg_yellow` | Start yellow background text. |
| `ansi_bg_yellow_i` | Start intense yellow background text. |

#### ANSI: ideogram and frames

| Function | Use case |
| --- | --- |
| `ansi_ig_left` | Start left ideogram line annotation. |
| `ansi_ig_left2` | Start double left ideogram line annotation. |
| `ansi_ig_right` | Start right ideogram line annotation. |
| `ansi_ig_right2` | Start double right ideogram line annotation. |
| `ansi_ig_stress` | Start ideogram stress marking. |
| `ansi_ig_reset` | End ideogram annotation. |
| `ansi_frame_encircle` | Start encircled text where supported. |
| `ansi_frame` | Start framed text where supported. |
| `ansi_frame_reset` | End framed or encircled text. |
| `ansi_frame_overline` | Start overlined text. |
| `ansi_frame_overline_off` | End overlined text. |

#### ANSI: terminal reports

Report functions query the terminal and print the response. They may fail or time out when stdin is not an interactive terminal.

| Function | Use case |
| --- | --- |
| `ansi_report REQUEST PREFIX SUFFIX` | Low-level terminal query used by the report helpers. |
| `ansi_report_pos` | Print the cursor position as `row,column`. |
| `ansi_report_icon` | Print the terminal icon title. |
| `ansi_report_screen_chars` | Print screen dimensions in character cells. |
| `ansi_report_title` | Print the terminal window title. |
| `ansi_report_window_chars` | Print window dimensions in character cells. |
| `ansi_report_window_pixels` | Print window dimensions in pixels. |
| `ansi_report_window_pos` | Print the window position. |
| `ansi_report_window_state` | Print whether the window is open, iconified, or unknown. |
