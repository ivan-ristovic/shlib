#!/bin/bash

# Validate an IPv4 address.
# Inputs:
#   $1 - Address string.
#
# Output:
#   None.
#
# Returns:
#   0 for a syntactically valid IPv4 address; 1 otherwise.
#
# Example:
#   net_is_ipv4 192.0.2.10
function net_is_ipv4 ()
{
    local -r regex='^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    [[ $1 =~ $regex ]]
    return $?
}

# Validate a fully qualified domain name.
# Inputs:
#   $1 - Domain name.
#
# Output:
#   None.
#
# Returns:
#   0 for a valid FQDN; 1 otherwise.
#
# Example:
#   net_is_fqdn example.com
function net_is_fqdn ()
{
    echo "$1" | grep -Pq '(?=^.{4,255}$)(^((?!-)[a-zA-Z0-9-]{1,63}(?<!-)\.)+[a-zA-Z]{2,63}\.?$)'
    return $?
}

# Validate a dotted IPv4 netmask.
# Inputs:
#   $1 - Netmask such as 255.255.255.0.
#
# Output:
#   None.
#
# Returns:
#   0 for a valid contiguous IPv4 netmask; 1 otherwise.
#
# Example:
#   net_is_ipv4_netmask 255.255.255.0
function net_is_ipv4_netmask ()
{
    local rest_to_zero=
    local -a ipb
    local i

    net_is_ipv4 "$1" || return 1

    IFS='.' read -r 'ipb[1]' 'ipb[2]' 'ipb[3]' 'ipb[4]' <<< "$1"

    local -r list_msb='0 128 192 224 240 248 252 254'

    for i in {1,2,3,4}; do
        if [[ ${rest_to_zero:-} ]]; then
            [[ ${ipb[i]} -eq 0 ]] || return 1
        else
            if [[ $list_msb =~ (^|[[:space:]])${ipb[i]}($|[[:space:]]) ]]; then
                rest_to_zero=1
            elif [[ ${ipb[i]} -eq 255 ]]; then
                continue
            else
                return 1
            fi
        fi
    done

    return 0
}

# Validate an IPv4 CIDR prefix length.
# Inputs:
#   $1 - Prefix length string.
#
# Output:
#   None.
#
# Returns:
#   0 for an integer from 0 to 32; 1 otherwise.
#
# Example:
#   net_is_ipv4_cidr 24
function net_is_ipv4_cidr ()
{
    local -r regex='^[[:digit:]]{1,2}$'

    [[ $1 =~ $regex ]] || return 1
    if [ "$1" -gt 32 ] || [ "$1" -lt 0 ]; then
        return 1
    fi

    return 0
}

# Validate an IPv4 subnet in address/prefix form.
# Inputs:
#   $1 - Subnet string such as 192.0.2.0/24.
#
# Output:
#   None.
#
# Returns:
#   0 for a valid IPv4 subnet; 1 otherwise.
#
# Example:
#   net_is_ipv4_subnet 192.0.2.0/24
function net_is_ipv4_subnet ()
{
    local tip tmask

    IFS='/' read -r tip tmask <<< "$1"

    net_is_ipv4_cidr "$tmask" || return 1
    net_is_ipv4 "$tip" || return 1

    return 0
}
