#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   ip.dhcp.client
# ===================================================================
# ALL package level functions follows lower camel case.
# This package provides functions to manage DHCP clients for IP allocation.
#
# Copyright (c) 2020-2025 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="ip.dhcp.client";
	"version"="0.7.0";
	"description"="This package provides functions to manage DHCP clients for IP allocation.";
	"essential"=false;
	"global"=false;
};


# $ensure
# Ensure the target interface has a DHCP client, leave it disabled if already disabled.
# kwargs: Params=<params>
# params:
#   kwargs: interface=<str>
#   opt kwargs: add-default-route=<bool>
#   opt kwargs: default-route-distance=<num>
#   opt kwargs: use-peer-dns=<bool>
#   opt kwargs: use-peer-ntp=<bool>
:local ensure do={
	#DEFINE global
	:global IsNil;
	:global IsEmpty;
	:global IsNothing;
	:global TypeofArray;
	:global TypeofStr;
	:global ReadOption;
	:global GetOrCreateEntity;
	# read params
	:local params [$ReadOption $Params $TypeofArray];
	:if ([$IsNil $params]) do={:error "ip.dhcp.client.ensure: require \$Params"}
	:if ([$IsEmpty $params]) do={:error "ip.dhcp.client.ensure: require options in \$Params"}
	# read opt
	:local intf [$ReadOption ($params->"interface") $TypeofStr];
	:if ([$IsNil $intf]) do={:error "ip.dhcp.client.ensure: require interface in \$Params"}
	:if ([$IsEmpty [/interface/find name=$intf]]) do={
		:error "ip.dhcp.client.ensure: target interface=$intf not found";
	}
	:if ([$IsNothing ($params->"add-default-route")]) do={
		:set ($params->"add-default-route") no;
	}
	:if ([$IsNothing ($params->"default-route-distance")]) do={
		:set ($params->"default-route-distance") 9;
	}
	:if ([$IsNothing ($params->"use-peer-dns")]) do={
		:set ($params->"use-peer-dns") no;
	}
	:if ([$IsNothing ($params->"use-peer-ntp")]) do={
		:set ($params->"use-peer-ntp") no;
	}
	# local
	:local iid [$GetOrCreateEntity "/ip/dhcp-client" $params]
	:return $iid;
}


:local package {
	"metaInfo"=$metaInfo;
	"ensure"=$ensure;
}
:return $package;
