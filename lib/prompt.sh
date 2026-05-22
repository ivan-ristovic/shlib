#!/bin/bash

# Ask an interactive yes/no question.
# Inputs:
#   $1 - Question text.
#   $2 - Optional mode: "yes", "no", or "required"; defaults to "required".
#
# Output:
#   Writes the prompt to stdout and reads from SHLIB_PROMPT_TTY or /dev/tty.
#
# Returns:
#   0 for yes; 1 for no or unreadable input; 2 for an invalid mode.
#
# Example:
#   if prompt_confirm "Deploy now?" no; then deploy; fi
function prompt_confirm ()
{
    local question="$1" mode="${2:-required}" prompt default reply tty fd

    case "$mode" in
        yes)
            prompt="Y/n"
            default=yes
            ;;
        no)
            prompt="y/N"
            default=no
            ;;
        required)
            prompt="y/n"
            default=
            ;;
        *)
            printf 'invalid confirm mode: %s\n' "$mode" >&2
            return 2
            ;;
    esac

    tty="${SHLIB_PROMPT_TTY:-/dev/tty}"
    exec {fd}< "$tty" || return 1

    while true; do
        printf '%s [%s] ' "$question" "$prompt"
        if ! IFS= read -r -u "$fd" reply; then
            exec {fd}<&-
            return 1
        fi

        if [[ -z "$reply" ]]; then
            reply="$default"
        fi

        case "$reply" in
            Y*|y*)
                exec {fd}<&-
                return 0
                ;;
            N*|n*)
                exec {fd}<&-
                return 1
                ;;
        esac
    done
}

# Read one interactive input line into a variable.
# Inputs:
#   $1 - Output variable name.
#   $2 - Prompt text.
#   $3 - Optional default value used for an empty reply.
#
# Output:
#   Writes the prompt to stdout and assigns the reply to the named variable.
#
# Returns:
#   0 on success; 1 when input cannot be read.
#
# Example:
#   prompt_input username "User" "$USER"
function prompt_input ()
{
    local -n _prompt_input_out_ref="$1"
    local prompt="$2" default="" reply tty fd
    local has_default=0

    if (($# >= 3)); then
        default="$3"
        has_default=1
    fi

    tty="${SHLIB_PROMPT_TTY:-/dev/tty}"
    exec {fd}< "$tty" || return 1

    if (( has_default )); then
        printf '%s [%s]: ' "$prompt" "$default"
    else
        printf '%s: ' "$prompt"
    fi

    if ! IFS= read -r -u "$fd" reply; then
        exec {fd}<&-
        return 1
    fi
    exec {fd}<&-

    if [[ -z "$reply" && $has_default -eq 1 ]]; then
        reply="$default"
    fi

    _prompt_input_out_ref="$reply"
}

# Let the user choose from numbered options.
# Inputs:
#   $1 - Output variable name.
#   $2 - Prompt text.
#   $@ - Option values after the prompt text.
#
# Output:
#   Writes the prompt and numbered options to stdout; assigns the selected
#   option to the named variable.
#
# Returns:
#   0 on valid selection; 1 when input cannot be read; 2 when no options are
#   provided.
#
# Example:
#   prompt_select color "Choose color" red green blue
function prompt_select ()
{
    local -n _prompt_select_out_ref="$1"
    local prompt="$2" tty fd choice i
    local -a options
    shift 2
    options=("$@")

    if ((${#options[@]} == 0)); then
        printf 'prompt_select requires at least one option\n' >&2
        return 2
    fi

    tty="${SHLIB_PROMPT_TTY:-/dev/tty}"
    exec {fd}< "$tty" || return 1

    while true; do
        printf '%s\n' "$prompt"
        i=1
        for choice in "${options[@]}"; do
            printf '%s) %s\n' "$i" "$choice"
            i=$((i + 1))
        done
        printf '> '

        if ! IFS= read -r -u "$fd" choice; then
            exec {fd}<&-
            return 1
        fi

        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#options[@]} )); then
            _prompt_select_out_ref="${options[choice - 1]}"
            exec {fd}<&-
            return 0
        fi
    done
}
