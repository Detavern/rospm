#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   cidr
# ===================================================================
# ALL package level functions follows lower camel case.
# Provides functions for managing collections of special CIDRs.
#
# Copyright (c) 2020-2025 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="cidr";
	"version"="0.7.0";
	"description"="Provides functions for managing collections of special CIDRs.";
};

# $ensureReserved
:local ensureReserved do={
	/ip/firewall/address-list/remove [/ip/firewall/address-list/find list=IP-CIDR_RESERVED];
	/ip/firewall/address-list/remove [/ip/firewall/address-list/find list=IP-CIDR_NO-FORWARD];
	/ip/firewall/address-list/remove [/ip/firewall/address-list/find list=IP-CIDR_BAD-PUBLIC];
	/ip/firewall/address-list/remove [/ip/firewall/address-list/find list=IP-CIDR_NO-GLOBAL-ROUTE];
	/ip/firewall/address-list/remove [/ip/firewall/address-list/find list=IP-CIDR_BAD-SRC];
	/ip/firewall/address-list/remove [/ip/firewall/address-list/find list=IP-CIDR_BAD-DST];
	/ip/firewall/address-list/remove [/ip/firewall/address-list/find list=IP-CIDR_NO-TRACK];
	# reserved
	/ip/firewall/address-list/add address=0.0.0.0/8 comment="Self-Identification" list=IP-CIDR_RESERVED
	/ip/firewall/address-list/add address=10.0.0.0/8 comment="Private CLASS A" list=IP-CIDR_RESERVED
	/ip/firewall/address-list/add address=172.16.0.0/12 comment="Private CLASS B" list=IP-CIDR_RESERVED
	/ip/firewall/address-list/add address=192.168.0.0/16 comment="Private CLASS C" list=IP-CIDR_RESERVED
	/ip/firewall/address-list/add address=224.0.0.0/4 comment="IP Multicast" list=IP-CIDR_RESERVED
	/ip/firewall/address-list/add address=240.0.0.0/4 comment="Reserved for future use" list=IP-CIDR_RESERVED
	/ip/firewall/address-list/add address=192.0.2.0/24 comment="TEST-NET-1" list=IP-CIDR_RESERVED
	/ip/firewall/address-list/add address=198.51.100.0/24 comment="TEST-NET-2" list=IP-CIDR_RESERVED
	/ip/firewall/address-list/add address=203.0.113.0/24 comment="TEST-NET-3" list=IP-CIDR_RESERVED
	/ip/firewall/address-list/add address=127.0.0.0/8 comment="Loopback" list=IP-CIDR_RESERVED
	/ip/firewall/address-list/add address=169.254.0.0/16 comment="Link Local" list=IP-CIDR_RESERVED
	/ip/firewall/address-list/add address=192.0.0.0/24 comment="IETF Protocol Assignments" list=IP-CIDR_RESERVED
	/ip/firewall/address-list/add address=192.88.99.0/24 comment="6to4 Relay Anycast" list=IP-CIDR_RESERVED
	/ip/firewall/address-list/add address=198.18.0.0/15 comment="Network Interconnect Device Benchmark Testing" list=IP-CIDR_RESERVED
	/ip/firewall/address-list/add address=255.255.255.255 comment="Limited Broadcast" list=IP-CIDR_RESERVED
	/ip/firewall/address-list/add address=100.64.0.0/10 comment="Carrier grade NAT" list=IP-CIDR_RESERVED
	# no forward
	/ip/firewall/address-list/add address=0.0.0.0/8 comment="Self-Identification" list=IP-CIDR_NO-FORWARD
	/ip/firewall/address-list/add address=169.254.0.0/16 comment="Link Local" list=IP-CIDR_NO-FORWARD
	/ip/firewall/address-list/add address=224.0.0.0/4 comment="IP Multicast" list=IP-CIDR_NO-FORWARD
	/ip/firewall/address-list/add address=255.255.255.255 comment="Limited Broadcast" list=IP-CIDR_NO-FORWARD
	# bad public
	/ip/firewall/address-list/add address=127.0.0.0/8 comment="Loopback" list=IP-CIDR_BAD-PUBLIC
	/ip/firewall/address-list/add address=192.0.0.0/24 comment="IETF Protocol Assignments" list=IP-CIDR_BAD-PUBLIC
	/ip/firewall/address-list/add address=192.0.2.0/24 comment="TEST-NET-1" list=IP-CIDR_BAD-PUBLIC
	/ip/firewall/address-list/add address=198.51.100.0/24 comment="TEST-NET-2" list=IP-CIDR_BAD-PUBLIC
	/ip/firewall/address-list/add address=203.0.113.0/24 comment="TEST-NET-3" list=IP-CIDR_BAD-PUBLIC
	/ip/firewall/address-list/add address=240.0.0.0/4 comment="Reserved for future use" list=IP-CIDR_BAD-PUBLIC
	# no global
	/ip/firewall/address-list/add address=0.0.0.0/8 comment="Self-Identification" list=IP-CIDR_NO-GLOBAL-ROUTE
	/ip/firewall/address-list/add address=10.0.0.0/8 comment="Private CLASS A" list=IP-CIDR_NO-GLOBAL-ROUTE
	/ip/firewall/address-list/add address=172.16.0.0/12 comment="Private CLASS B" list=IP-CIDR_NO-GLOBAL-ROUTE
	/ip/firewall/address-list/add address=192.168.0.0/16 comment="Private CLASS C" list=IP-CIDR_NO-GLOBAL-ROUTE
	/ip/firewall/address-list/add address=100.64.0.0/10 comment="Carrier grade NAT" list=IP-CIDR_NO-GLOBAL-ROUTE
	/ip/firewall/address-list/add address=169.254.0.0/16 comment="Link Local" list=IP-CIDR_NO-GLOBAL-ROUTE
	/ip/firewall/address-list/add address=192.0.0.0/29 comment="IETF Protocol Assignments" list=IP-CIDR_NO-GLOBAL-ROUTE
	/ip/firewall/address-list/add address=198.18.0.0/15 comment="Network Interconnect Device Benchmark Testing" list=IP-CIDR_NO-GLOBAL-ROUTE
	/ip/firewall/address-list/add address=255.255.255.255 comment="Limited Broadcast" list=IP-CIDR_NO-GLOBAL-ROUTE
	# bad src
	/ip/firewall/address-list/add address=224.0.0.0/4 comment="IP Multicast" list=IP-CIDR_BAD-SRC
	/ip/firewall/address-list/add address=255.255.255.255 comment="Limited Broadcast" list=IP-CIDR_BAD-SRC
	# bad dst
	/ip/firewall/address-list/add address=0.0.0.0/8 comment="Self-Identification" list=IP-CIDR_BAD-DST
	# no track
	/ip/firewall/address-list/add address=169.254.0.0/16 comment="Link Local" list=IP-CIDR_NO-TRACK
}

:local package {
	"metaInfo"=$metaInfo;
	"ensureReserved"=$ensureReserved;
}
:return $package;
