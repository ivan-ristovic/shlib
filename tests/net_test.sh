#!/usr/bin/env bash
set -u

source "$(dirname "${BASH_SOURCE[0]}")/helper.bash"
source "$SHLIB_ROOT/net.sh"

test_net_ipv4() {
    assert_success net_is_ipv4 "192.168.0.1"
    assert_success net_is_ipv4 "0.0.0.0"
    assert_success net_is_ipv4 "255.255.255.255"
    assert_failure net_is_ipv4 "256.1.1.1"
    assert_failure net_is_ipv4 "1.2.3"
}

test_net_fqdn() {
    assert_success net_is_fqdn "example.com"
    assert_success net_is_fqdn "api.example.co.uk"
    assert_failure net_is_fqdn "-bad.example.com"
    assert_failure net_is_fqdn "localhost"
}

test_net_masks_and_subnets() {
    assert_success net_is_ipv4_netmask "255.255.255.0"
    assert_success net_is_ipv4_netmask "255.255.252.0"
    assert_failure net_is_ipv4_netmask "255.0.255.0"
    assert_failure net_is_ipv4_netmask "255.255.255.1"

    assert_success net_is_ipv4_cidr "0"
    assert_success net_is_ipv4_cidr "32"
    assert_failure net_is_ipv4_cidr "33"
    assert_failure net_is_ipv4_cidr "-1"
    assert_failure net_is_ipv4_cidr "abc"

    assert_success net_is_ipv4_subnet "192.168.0.0/24"
    assert_failure net_is_ipv4_subnet "192.168.0.0/33"
    assert_failure net_is_ipv4_subnet "999.168.0.0/24"
}

run_test "IPv4 validation" test_net_ipv4
run_test "FQDN validation" test_net_fqdn
run_test "netmask, CIDR, and subnet validation" test_net_masks_and_subnets

finish_tests
