#!/bin/bash

_ARGS_SEP=$'\034'

function _args_valid_type ()
{
    case "$1" in
        flag|string|int)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

function _args_read_spec ()
{
    local _args_read_entry="$1"
    local -n _args_read_name_ref="$2"
    local -n _args_read_type_ref="$3"
    local -n _args_read_short_ref="$4"
    local -n _args_read_long_ref="$5"
    local -n _args_read_default_ref="$6"
    local -n _args_read_help_ref="$7"

    IFS="$_ARGS_SEP" read -r \
        _args_read_name_ref \
        _args_read_type_ref \
        _args_read_short_ref \
        _args_read_long_ref \
        _args_read_default_ref \
        _args_read_help_ref <<< "$_args_read_entry"
}

function _args_find_by_long ()
{
    local -n _args_find_long_specs_ref="$1"
    local _args_find_long="$2"
    local -n _args_find_long_out_ref="$3"
    local _args_find_long_entry _args_find_long_name _args_find_long_type
    local _args_find_long_short _args_find_long_long _args_find_long_default _args_find_long_help

    for _args_find_long_entry in "${_args_find_long_specs_ref[@]}"; do
        _args_read_spec "$_args_find_long_entry" \
            _args_find_long_name \
            _args_find_long_type \
            _args_find_long_short \
            _args_find_long_long \
            _args_find_long_default \
            _args_find_long_help
        if [[ "$_args_find_long_long" == "$_args_find_long" ]]; then
            _args_find_long_out_ref="$_args_find_long_entry"
            return 0
        fi
    done

    return 1
}

function _args_find_by_short ()
{
    local -n _args_find_short_specs_ref="$1"
    local _args_find_short="$2"
    local -n _args_find_short_out_ref="$3"
    local _args_find_short_entry _args_find_short_name _args_find_short_type
    local _args_find_short_short _args_find_short_long _args_find_short_default _args_find_short_help

    for _args_find_short_entry in "${_args_find_short_specs_ref[@]}"; do
        _args_read_spec "$_args_find_short_entry" \
            _args_find_short_name \
            _args_find_short_type \
            _args_find_short_short \
            _args_find_short_long \
            _args_find_short_default \
            _args_find_short_help
        if [[ "$_args_find_short_short" == "$_args_find_short" ]]; then
            _args_find_short_out_ref="$_args_find_short_entry"
            return 0
        fi
    done

    return 1
}

function _args_store_value ()
{
    local -n _args_store_opts_ref="$1"
    local _args_store_spec="$2" _args_store_value="$3"
    local _args_store_name _args_store_type _args_store_short
    local _args_store_long _args_store_default _args_store_help

    _args_read_spec "$_args_store_spec" \
        _args_store_name \
        _args_store_type \
        _args_store_short \
        _args_store_long \
        _args_store_default \
        _args_store_help
    if [[ "$_args_store_type" == int && ! "$_args_store_value" =~ ^-?[0-9]+$ ]]; then
        printf 'invalid value for %s: expected int\n' "$_args_store_name" >&2
        return 2
    fi

    _args_store_opts_ref["$_args_store_name"]="$_args_store_value"
}

# Add an option definition to an argument parser spec.
# Inputs:
#   $1 - Name of the indexed spec array to append to.
#   $2 - Parsed option name used as the key in the output associative array.
#   $3 - Type: "flag", "string", or "int".
#   $4 - Short option character, with or without a leading dash; empty allowed.
#   $5 - Long option name, with or without leading dashes.
#   $6 - Default parsed value.
#   $7 - Help text for args_usage.
#
# Output:
#   None; appends one encoded spec entry to the named array.
#
# Returns:
#   0 on success; 2 for invalid type, invalid short option, missing names, or
#   duplicate option definitions.
#
# Example:
#   args_spec_add spec verbose flag v verbose false "Enable verbose output"
function args_spec_add ()
{
    local -n _args_add_specs_ref="$1"
    local _args_add_name="$2" _args_add_type="$3" _args_add_short="${4:-}" _args_add_long="${5:-}"
    local _args_add_default="${6:-}" _args_add_help="${7:-}"
    local _args_add_entry _args_add_spec_name _args_add_spec_type _args_add_spec_short
    local _args_add_spec_long _args_add_spec_default _args_add_spec_help

    _args_valid_type "$_args_add_type" || {
        printf 'invalid option type for %s: %s\n' "$_args_add_name" "$_args_add_type" >&2
        return 2
    }

    _args_add_short="${_args_add_short#-}"
    _args_add_long="${_args_add_long#--}"

    if [[ -n "$_args_add_short" && ${#_args_add_short} -ne 1 ]]; then
        printf 'invalid short option for %s: %s\n' "$_args_add_name" "$_args_add_short" >&2
        return 2
    fi

    if [[ -z "$_args_add_name" || -z "$_args_add_long" ]]; then
        printf 'option name and long option are required\n' >&2
        return 2
    fi

    for _args_add_entry in "${_args_add_specs_ref[@]}"; do
        _args_read_spec "$_args_add_entry" \
            _args_add_spec_name \
            _args_add_spec_type \
            _args_add_spec_short \
            _args_add_spec_long \
            _args_add_spec_default \
            _args_add_spec_help
        if [[ "$_args_add_spec_name" == "$_args_add_name" || "$_args_add_spec_long" == "$_args_add_long" || ( -n "$_args_add_short" && "$_args_add_spec_short" == "$_args_add_short" ) ]]; then
            printf 'duplicate option: %s\n' "$_args_add_name" >&2
            return 2
        fi
    done

    _args_add_specs_ref+=("${_args_add_name}${_ARGS_SEP}${_args_add_type}${_ARGS_SEP}${_args_add_short}${_ARGS_SEP}${_args_add_long}${_ARGS_SEP}${_args_add_default}${_ARGS_SEP}${_args_add_help}")
}

# Parse command-line options and positional arguments.
# Inputs:
#   $1 - Name of the indexed spec array.
#   $2 - Name of the associative array to receive parsed option values.
#   $3 - Name of the indexed array to receive positional arguments.
#   $@ - Arguments to parse after the three array names.
#
# Output:
#   Writes parse errors to stderr; mutates the named output arrays.
#
# Returns:
#   0 on success; 2 for unknown options, missing values, invalid int values, or
#   unsupported option forms.
#
# Example:
#   args_parse spec opts positionals "$@" || exit 2
function args_parse ()
{
    local -n _args_parse_specs_ref="$1"
    local -n _args_parse_opts_ref="$2"
    local -n _args_parse_positionals_ref="$3"
    local _args_parse_specs_name="$1"
    local _args_parse_opts_name="$2"
    local _args_parse_arg _args_parse_option _args_parse_value _args_parse_entry
    local _args_parse_name _args_parse_type _args_parse_short
    local _args_parse_long _args_parse_default _args_parse_help
    shift 3

    _args_parse_opts_ref=()
    _args_parse_positionals_ref=()

    for _args_parse_entry in "${_args_parse_specs_ref[@]}"; do
        _args_read_spec "$_args_parse_entry" \
            _args_parse_name \
            _args_parse_type \
            _args_parse_short \
            _args_parse_long \
            _args_parse_default \
            _args_parse_help
        if [[ "$_args_parse_type" == flag && -z "$_args_parse_default" ]]; then
            _args_parse_default=false
        fi
        _args_parse_opts_ref["$_args_parse_name"]="$_args_parse_default"
    done

    while (($# > 0)); do
        _args_parse_arg="$1"
        case "$_args_parse_arg" in
            --)
                shift
                _args_parse_positionals_ref+=("$@")
                break
                ;;
            --no-*)
                _args_parse_option="${_args_parse_arg#--no-}"
                if ! _args_find_by_long "$_args_parse_specs_name" "$_args_parse_option" _args_parse_entry; then
                    printf 'unknown option: --no-%s\n' "$_args_parse_option" >&2
                    return 2
                fi
                _args_read_spec "$_args_parse_entry" _args_parse_name _args_parse_type _args_parse_short _args_parse_long _args_parse_default _args_parse_help
                if [[ "$_args_parse_type" != flag ]]; then
                    printf 'option does not support --no- form: --%s\n' "$_args_parse_long" >&2
                    return 2
                fi
                _args_parse_opts_ref["$_args_parse_name"]=false
                shift
                ;;
            --*=*)
                _args_parse_option="${_args_parse_arg%%=*}"
                _args_parse_option="${_args_parse_option#--}"
                _args_parse_value="${_args_parse_arg#*=}"
                if ! _args_find_by_long "$_args_parse_specs_name" "$_args_parse_option" _args_parse_entry; then
                    printf 'unknown option: --%s\n' "$_args_parse_option" >&2
                    return 2
                fi
                _args_read_spec "$_args_parse_entry" _args_parse_name _args_parse_type _args_parse_short _args_parse_long _args_parse_default _args_parse_help
                if [[ "$_args_parse_type" == flag ]]; then
                    printf 'option does not take a value: --%s\n' "$_args_parse_long" >&2
                    return 2
                fi
                _args_store_value "$_args_parse_opts_name" "$_args_parse_entry" "$_args_parse_value" || return 2
                shift
                ;;
            --*)
                _args_parse_option="${_args_parse_arg#--}"
                if ! _args_find_by_long "$_args_parse_specs_name" "$_args_parse_option" _args_parse_entry; then
                    printf 'unknown option: --%s\n' "$_args_parse_option" >&2
                    return 2
                fi
                _args_read_spec "$_args_parse_entry" _args_parse_name _args_parse_type _args_parse_short _args_parse_long _args_parse_default _args_parse_help
                if [[ "$_args_parse_type" == flag ]]; then
                    _args_parse_opts_ref["$_args_parse_name"]=true
                    shift
                else
                    if (($# < 2)); then
                        printf 'missing value for option: --%s\n' "$_args_parse_long" >&2
                        return 2
                    fi
                    _args_store_value "$_args_parse_opts_name" "$_args_parse_entry" "$2" || return 2
                    shift 2
                fi
                ;;
            -*)
                _args_parse_option="${_args_parse_arg#-}"
                if [[ ${#_args_parse_option} -ne 1 ]]; then
                    printf 'short option clusters are not supported: -%s\n' "$_args_parse_option" >&2
                    return 2
                fi
                if ! _args_find_by_short "$_args_parse_specs_name" "$_args_parse_option" _args_parse_entry; then
                    printf 'unknown option: -%s\n' "$_args_parse_option" >&2
                    return 2
                fi
                _args_read_spec "$_args_parse_entry" _args_parse_name _args_parse_type _args_parse_short _args_parse_long _args_parse_default _args_parse_help
                if [[ "$_args_parse_type" == flag ]]; then
                    _args_parse_opts_ref["$_args_parse_name"]=true
                    shift
                else
                    if (($# < 2)); then
                        printf 'missing value for option: -%s\n' "$_args_parse_short" >&2
                        return 2
                    fi
                    _args_store_value "$_args_parse_opts_name" "$_args_parse_entry" "$2" || return 2
                    shift 2
                fi
                ;;
            *)
                _args_parse_positionals_ref+=("$_args_parse_arg")
                shift
                ;;
        esac
    done
}

# Print usage text from an argument parser spec.
# Inputs:
#   $1 - Name of the indexed spec array.
#   $2 - Command name to display.
#   $3 - Optional summary text.
#
# Output:
#   Writes usage and option help to stdout.
#
# Returns:
#   0 unless printf fails or the spec array name is invalid.
#
# Example:
#   args_usage spec "${0##*/}" "Run the command."
function args_usage ()
{
    local -n _args_usage_specs_ref="$1"
    local _args_usage_command="$2" _args_usage_summary="${3:-}"
    local _args_usage_entry _args_usage_name _args_usage_type _args_usage_short
    local _args_usage_long _args_usage_default _args_usage_help _args_usage_label

    printf 'Usage: %s [OPTIONS] [ARGS...]\n' "$_args_usage_command"
    if [[ -n "$_args_usage_summary" ]]; then
        printf '\n%s\n' "$_args_usage_summary"
    fi

    if ((${#_args_usage_specs_ref[@]} > 0)); then
        printf '\nOptions:\n'
    fi

    for _args_usage_entry in "${_args_usage_specs_ref[@]}"; do
        _args_read_spec "$_args_usage_entry" \
            _args_usage_name \
            _args_usage_type \
            _args_usage_short \
            _args_usage_long \
            _args_usage_default \
            _args_usage_help
        _args_usage_label=
        if [[ -n "$_args_usage_short" ]]; then
            _args_usage_label="-$_args_usage_short, "
        fi
        _args_usage_label="${_args_usage_label}--$_args_usage_long"
        if [[ "$_args_usage_type" != flag ]]; then
            _args_usage_label="$_args_usage_label VALUE"
        fi
        if [[ -n "$_args_usage_default" ]]; then
            _args_usage_help="$_args_usage_help (default: $_args_usage_default)"
        fi
        printf '  %-24s %s\n' "$_args_usage_label" "$_args_usage_help"
    done
}
