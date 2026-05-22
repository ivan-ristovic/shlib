#!/bin/bash

PI='3.141592653589793'
# Public constant for callers.
# shellcheck disable=SC2034
TAU='6.283185307179586'
# Public constant for callers.
# shellcheck disable=SC2034
E='2.718281828459045'

export SHLIB_MATH_SCALE=8

# Print the integer part of a decimal value.
# Inputs:
#   $1 - Numeric value; prompts interactively when omitted.
#
# Output:
#   Writes the part before the decimal point to stdout.
#
# Returns:
#   0 unless argument prompting fails.
#
# Example:
#   math_int 12.75
function math_int ()
{
    eval "$(_math_args_or_input "$@")"
    echo "${1%.*}"
}

# Print the fractional part of a decimal value.
# Inputs:
#   $1 - Numeric value; prompts interactively when omitted.
#
# Output:
#   Writes the decimal point and fractional digits, or nothing for integers.
#
# Returns:
#   0 unless argument prompting fails.
#
# Example:
#   math_frac 12.75
function math_frac ()
{
    eval "$(_math_args_or_input "$@")"
    if [[ "$1" =~ \. ]]; then
        echo ".${1#*.}"
    fi
}

# Evaluate a bc expression with shlib math functions loaded.
# Inputs:
#   $1 - bc expression; prompts interactively when omitted.
#   $2 - Optional scale; defaults to SHLIB_MATH_SCALE.
#
# Output:
#   Writes the bc result to stdout.
#
# Returns:
#   The status from bc.
#
# Example:
#   math_compute "sqrt(9)" 4
function math_compute ()
{
    eval "$(_math_args_or_input "$@")"
    (_math_bc_functions
     echo "scale=${2:-$SHLIB_MATH_SCALE} ; "
     echo "$1"
    ) | bc -lq 2>/dev/null
}

# Evaluate a numeric expression as a shell condition.
# Inputs:
#   $1 - bc expression that should evaluate to 0 or 1.
#   $2 - Optional scale; defaults to SHLIB_MATH_SCALE.
#
# Output:
#   None.
#
# Returns:
#   0 when the expression evaluates to 1; 1 otherwise.
#
# Example:
#   if math_cond "3 > 2"; then echo true; fi
function math_cond ()
{
    eval "$(_math_args_or_input "$@")"
    local cond=0 scale=${2:-$SHLIB_MATH_SCALE}
    if (( $# > 0 )); then
        cond="$(math_compute "$1" "$scale")"
        if [[ -z "$cond" ]]; then cond=0; fi
        if [[ "$cond" != 0  && "$cond" != 1 ]]; then cond=0; fi
    fi
    local stat=$((cond == 0))
    return $stat
}

# Evaluate a math expression and require a non-empty result.
# Inputs:
#   $1 - bc expression; prompts interactively when omitted.
#   $2 - Optional scale; defaults to SHLIB_MATH_SCALE.
#
# Output:
#   Writes the result to stdout.
#
# Returns:
#   0 when bc succeeds and produces output; 1 otherwise.
#
# Example:
#   result=$(math_eval "2^8")
function math_eval ()
{
    eval "$(_math_args_or_input "$@")"
    local exc=0 res=0 scale="${2:-$SHLIB_MATH_SCALE}"
    if (( $# > 0 )) ; then
        res=$(math_compute "$1" "$scale")
        exc=$?
        if [[ $exc -eq 0 && -z "$res" ]]; then exc=1; fi
    fi
    echo "$res"
    return $exc
}

# Calculate sine for a radian value.
# Inputs:
#   $1 - Radian value.
#   $2 - Optional scale.
#
# Output:
#   Writes the sine result to stdout.
#
# Returns:
#   The status from math_eval.
#
# Example:
#   math_sin "$PI/2"
function math_sin    () { eval "$(_math_args_or_input "$@")" ; math_eval "s($1)"           "${2:-$SHLIB_MATH_SCALE}" ; }
# Calculate cosine for a radian value.
# Inputs:
#   $1 - Radian value.
#   $2 - Optional scale.
#
# Output:
#   Writes the cosine result to stdout.
#
# Returns:
#   The status from math_eval.
#
# Example:
#   math_cos 0
function math_cos    () { eval "$(_math_args_or_input "$@")" ; math_eval "c($1)"           "${2:-$SHLIB_MATH_SCALE}" ; }
# Calculate tangent for a radian value.
# Inputs:
#   $1 - Radian value.
#   $2 - Optional scale.
#
# Output:
#   Writes the tangent result to stdout.
#
# Returns:
#   The status from math_eval.
#
# Example:
#   math_tan "$PI/4"
function math_tan    () { eval "$(_math_args_or_input "$@")" ; math_eval "(s($1)/c($1))"   "${2:-$SHLIB_MATH_SCALE}" ; }
# Calculate cotangent for a radian value.
# Inputs:
#   $1 - Radian value.
#   $2 - Optional scale.
#
# Output:
#   Writes the cotangent result to stdout.
#
# Returns:
#   The status from math_eval.
#
# Example:
#   math_cotan "$PI/4"
function math_cotan  () { eval "$(_math_args_or_input "$@")" ; math_eval "(c($1)/s($1))"   "${2:-$SHLIB_MATH_SCALE}" ; }
# Calculate secant for a radian value.
# Inputs:
#   $1 - Radian value.
#   $2 - Optional scale.
#
# Output:
#   Writes the secant result to stdout.
#
# Returns:
#   The status from math_eval.
#
# Example:
#   math_sec 0
function math_sec    () { eval "$(_math_args_or_input "$@")" ; math_eval "(1/c($1))"       "${2:-$SHLIB_MATH_SCALE}" ; }
# Calculate cosecant for a radian value.
# Inputs:
#   $1 - Radian value.
#   $2 - Optional scale.
#
# Output:
#   Writes the cosecant result to stdout.
#
# Returns:
#   The status from math_eval.
#
# Example:
#   math_cosec "$PI/2"
function math_cosec  () { eval "$(_math_args_or_input "$@")" ; math_eval "(1/s($1))"       "${2:-$SHLIB_MATH_SCALE}" ; }
# Alias-style cosecant helper.
# Inputs:
#   $@ - Arguments passed to math_cosec.
#
# Output:
#   Writes the cosecant result to stdout.
#
# Returns:
#   The status from math_cosec.
#
# Example:
#   math_csc "$PI/2"
function math_csc    () { eval "$(_math_args_or_input "$@")" ; math_cosec "$@" ; }
# Calculate arcsine.
# Inputs:
#   $1 - Numeric value.
#   $2 - Optional scale.
#
# Output:
#   Writes the radian result to stdout.
#
# Returns:
#   The status from math_eval.
#
# Example:
#   math_asin 1
function math_asin   () { eval "$(_math_args_or_input "$@")" ; math_eval "asin($1)"        "${2:-$SHLIB_MATH_SCALE}" ; }
# Calculate arccosine.
# Inputs:
#   $1 - Numeric value.
#   $2 - Optional scale.
#
# Output:
#   Writes the radian result to stdout.
#
# Returns:
#   The status from math_eval.
#
# Example:
#   math_acos 1
function math_acos   () { eval "$(_math_args_or_input "$@")" ; math_eval "acos($1)"        "${2:-$SHLIB_MATH_SCALE}" ; }
# Calculate arctangent.
# Inputs:
#   $1 - Numeric value.
#   $2 - Optional scale.
#
# Output:
#   Writes the radian result to stdout.
#
# Returns:
#   The status from math_eval.
#
# Example:
#   math_atan 1
function math_atan   () { eval "$(_math_args_or_input "$@")" ; math_eval "atan($1)"        "${2:-$SHLIB_MATH_SCALE}" ; }
# Calculate arccotangent.
# Inputs:
#   $1 - Numeric value.
#   $2 - Optional scale.
#
# Output:
#   Writes the radian result to stdout.
#
# Returns:
#   The status from math_eval.
#
# Example:
#   math_arccot 1
function math_arccot () { eval "$(_math_args_or_input "$@")" ; math_eval "(($PI/2)-a($1))" "${2:-$SHLIB_MATH_SCALE}" ; }
# Alias-style arcsine helper.
# Inputs:
#   $@ - Arguments passed to math_asin.
#
# Output:
#   Writes the radian result to stdout.
#
# Returns:
#   The status from math_asin.
#
# Example:
#   math_arcsin 1
function math_arcsin () { eval "$(_math_args_or_input "$@")" ; math_asin "$@" ; }
# Alias-style arccosine helper.
# Inputs:
#   $@ - Arguments passed to math_acos.
#
# Output:
#   Writes the radian result to stdout.
#
# Returns:
#   The status from math_acos.
#
# Example:
#   math_arccos 1
function math_arccos () { eval "$(_math_args_or_input "$@")" ; math_acos "$@" ; }
# Alias-style arctangent helper.
# Inputs:
#   $@ - Arguments passed to math_atan.
#
# Output:
#   Writes the radian result to stdout.
#
# Returns:
#   The status from math_atan.
#
# Example:
#   math_arctan 1
function math_arctan () { eval "$(_math_args_or_input "$@")" ; math_atan "$@" ; }
# Calculate the natural logarithm.
# Inputs:
#   $1 - Numeric value.
#   $2 - Optional scale.
#
# Output:
#   Writes the natural log result to stdout.
#
# Returns:
#   The status from math_eval.
#
# Example:
#   math_ln "$E"
function math_ln     () { eval "$(_math_args_or_input "$@")" ; math_eval "l($1)"           "${2:-$SHLIB_MATH_SCALE}" ; }
# Calculate the base-10 logarithm.
# Inputs:
#   $1 - Numeric value.
#   $2 - Optional scale.
#
# Output:
#   Writes the base-10 log result to stdout.
#
# Returns:
#   The status from math_eval.
#
# Example:
#   math_log10 100
function math_log10  () { eval "$(_math_args_or_input "$@")" ; math_eval "l($1)/l(10.0)"   "${2:-$SHLIB_MATH_SCALE}" ; }
# Alias-style base-10 logarithm helper.
# Inputs:
#   $@ - Arguments passed to math_log10.
#
# Output:
#   Writes the base-10 log result to stdout.
#
# Returns:
#   The status from math_log10.
#
# Example:
#   math_log 100
function math_log    () { eval "$(_math_args_or_input "$@")" ; math_log10 "$@" ; }
# Calculate e raised to a power.
# Inputs:
#   $1 - Exponent.
#   $2 - Optional scale.
#
# Output:
#   Writes the exponential result to stdout.
#
# Returns:
#   The status from math_eval.
#
# Example:
#   math_exp 1
function math_exp    () { eval "$(_math_args_or_input "$@")" ; math_eval "e($1)"           "${2:-$SHLIB_MATH_SCALE}" ; }
# Raise a number to a power.
# Inputs:
#   $1 - Base.
#   $2 - Exponent.
#   $3 - Optional scale.
#
# Output:
#   Writes the power result to stdout.
#
# Returns:
#   The status from math_eval.
#
# Example:
#   math_pow 2 8
function math_pow    () { eval "$(_math_args_or_input "$@")" ; math_eval "$1^$2"           "${3:-$SHLIB_MATH_SCALE}" ; }
# Convert radians to degrees.
# Inputs:
#   $1 - Radian value.
#   $2 - Optional scale.
#
# Output:
#   Writes degrees to stdout.
#
# Returns:
#   The status from math_eval.
#
# Example:
#   math_deg "$PI"
function math_deg    () { eval "$(_math_args_or_input "$@")" ; math_eval "deg($1)"         "${2:-$SHLIB_MATH_SCALE}" ; }
# Convert radians to normalized degrees.
# Inputs:
#   $1 - Radian value.
#   $2 - Optional scale.
#
# Output:
#   Writes degrees normalized into the 0..360 range.
#
# Returns:
#   The status from math_eval.
#
# Example:
#   math_ndeg "-$PI"
function math_ndeg   () { eval "$(_math_args_or_input "$@")" ; math_eval "ndeg($1)"        "${2:-$SHLIB_MATH_SCALE}" ; }
# Convert degrees to radians.
# Inputs:
#   $1 - Degree value.
#   $2 - Optional scale.
#
# Output:
#   Writes radians to stdout.
#
# Returns:
#   The status from math_eval.
#
# Example:
#   math_rad 180
function math_rad    () { eval "$(_math_args_or_input "$@")" ; math_eval "rad($1)"         "${2:-$SHLIB_MATH_SCALE}" ; }
# Calculate absolute value.
# Inputs:
#   $1 - Numeric value.
#
# Output:
#   Writes the absolute value to stdout.
#
# Returns:
#   The status from math_eval.
#
# Example:
#   math_abs -42
function math_abs    () { eval "$(_math_args_or_input "$@")" ; math_eval "abs($1)" ; }
# Calculate the hypotenuse from two sides.
# Inputs:
#   $1 - First side.
#   $2 - Second side.
#   $3 - Optional scale.
#
# Output:
#   Writes sqrt(A^2 + B^2) to stdout.
#
# Returns:
#   The status from math_eval.
#
# Example:
#   math_hypot 3 4
function math_hypot  () { eval "$(_math_args_or_input "$@")" ; math_eval "sqrt(($1)^2 + ($2)^2)" "${3:-$SHLIB_MATH_SCALE}" ; }
# Round a decimal value.
# Inputs:
#   $1 - Numeric value.
#   $2 - Optional decimal places.
#
# Output:
#   Writes the rounded value to stdout.
#
# Returns:
#   The status from math_eval.
#
# Example:
#   math_round 3.14159 2
function math_round  () { eval "$(_math_args_or_input "$@")" ; math_eval "round($1, ${2:-(scale($1)-1)})" "${2:-$SHLIB_MATH_SCALE}" ; }

function _math_bc_functions ()
{
    cat <<'EOF'
    define pi()       { auto r,s ; s=scale; scale=10 ; r=4*a(1);         scale=s ; return(r) ; }
    define int(x)     { auto r,s ; s=scale; scale=0  ; r=((x - x%1)/1) ; scale=s ; return(r) ; }
    define frac(x)    { auto r,s ; s=scale; scale=0  ; r=(x%1) ;         scale=s ; return(r) ; }
    define sin(x)     { return(s(x))                     ; }
    define cos(x)     { return(c(x))                     ; }
    define tan(x)     { return(s(x)/c(x))                ; }
    define asin(x)    { return(2*a(x/(1+sqrt(1-(x^2))))) ; }
    define acos(x)    { return(2*a(sqrt(1-(x^2))/(1+x))) ; }
    define atan(x)    { return(a(x))                     ; }
    define logn(x)    { return(l(x))                     ; }
    define log(x)     { return(l(x)/l(10.0))             ; }
    define log10(x)   { return(log(x))                   ; }
    define exp(x)     { return(e(x))                     ; }
    define pow(x,y)   { return(x^y)                      ; }
    define rad(x)     { return(x*pi()/180)               ; }
    define deg(x)     { return(x*180/pi())               ; }
    define ndeg(x)    { return((360 + deg(x))%360)       ; }
    define round(x,s) { auto r,o
                      o=scale(x) ; scale=s+1
                      r = x + 5*10^(-(s+1))
                      scale=s
                      return(r/1) ; }
    define abs(x)     { if ( x<0 ) return(-x) else return(x) ; }
EOF
}

function _math_args_or_input ()
{
    local -a args

    if (( $# == 0 )) ; then
        local func="${FUNCNAME[1]}"
        while (( ${#args[*]} == 0 )); do
            read -rp "$func? " -a args
        done
    else
        args=("$@")
    fi

    printf 'set --'
    printf ' %q' "${args[@]}"
    printf '\n'
}
