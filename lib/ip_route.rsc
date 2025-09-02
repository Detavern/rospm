#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   ip.route
# ===================================================================
# ALL package level functions follows lower camel case.
# This package provides functions to facilitate routing and manage IP routes in RouterOS.
#
# Copyright (c) 2020-2025 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="ip.route";
	"version"="0.7.0";
	"description"="This package provides functions to facilitate routing and manage IP routes in RouterOS.";
};


# $getGateway
# kwargs: DstAddress=<str>
# kwargs: RoutingTable=<str>
# opt kwargs: NoSuffix=<bool>
# return: Gateway=<str>
:local getGateway do={
	#DEFINE global
	:global IsNil;
	:global IsEmpty;
	:global IsIPPrefix;
	:global TypeofStr;
	:global TypeofBool;
	:global ReadOption;
	# read opt
	:local pDstAddress [$ReadOption $DstAddress $TypeofStr];
	:local pRoutingTable [$ReadOption $RoutingTable $TypeofStr];
	:local pNoSuffix [$ReadOption $NoSuffix $TypeofBool false];
	# check params
	:if ([$IsNil $pDstAddress]) do={
		:error "getGateway: require \$DstAddress";
	}
	:if ([$IsNil $pRoutingTable]) do={
		:error "getGateway: require \$RoutingTable";
	}
	# check if has routing mark
	:local routeIDList [/ip/route/find dst-address=$pDstAddress active=yes routing-table=$pRoutingTable];
	:if ([$IsEmpty $routeIDList]) do={
		:error "getGateway: gateway for $pDstAddress with mark $pRoutingTable not found"
	}
	# gateway
	:local gw [:tostr [/ip/route/get ($routeIDList->0) gateway]];
	:if (!$pNoSuffix) do={
		:return $gw;
	}
	# check gateway like 1.1.1.1%ether1
	:local sPos [:find $gw "%"];
	:if ([$IsNil $sPos]) do={
		:return $gw;
	} else {
		:return [:pick $gw 0 $sPos];
	}
}


# $ensure
# kwargs: Params=<params>
# params:
#   opt kwargs: comment=<str>
#   opt kwargs: dst-address=<str>
#   opt kwargs: gateway=<str>
#   opt kwargs: routing-table=<str>
#   opt kwargs: distance=<num>
#   opt kwargs: table=<str>
#   opt kwargs: check-gateway=<str>
#   opt kwargs: dst-address-list=<str>, use first address in the list as dst-address
#   opt kwargs: gateway-address-list=<str>, use first address in the list as gateway
:local ensure do={
	#DEFINE global
	:global IsNil;
	:global IsEmpty;
	:global IsNothing;
	:global TypeofArray;
	:global TypeofStr;
	:global TypeofNum;
	:global ReadOption;
	:global GetOrCreateEntity;
	# read params
	:local params [$ReadOption $Params $TypeofArray];
	:if ([$IsNil $params]) do={:error "ip.route.ensure: require \$Params"}
	:if ([$IsEmpty $params]) do={:error "ip.route.ensure: require options in \$Params"}
	# read opt
	:local dstAddrList [$ReadOption ($params->"dst-address-list") $TypeofStr];
	:local gwAddrList [$ReadOption ($params->"gateway-address-list") $TypeofStr];
	:if (![$IsNil $dstAddrList]) do={
		:set ($params->"dst-address-list");
		:local idList [/ip/firewall/address-list/find list=$dstAddrList];
		:if ([:len $idList] > 0) do={
			:set ($params->"dst-address") [/ip/firewall/address-list/get ($idList->0) address];
		} else {
			:error ("ip.route.ensure: address not found in dst-address-list=$dstAddrList");
		}
	}
	:if (![$IsNil $gwAddrList]) do={
		:set ($params->"gateway-address-list");
		:local idList [/ip/firewall/address-list/find list=$gwAddrList];
		:if ([:len $idList] > 0) do={
			:set ($params->"gateway") [/ip/firewall/address-list/get ($idList->0) address];
		} else {
			:error ("ip.route.ensure: address not found in gateway-address-list=$gwAddrList");
		}
	}
	:if ([$IsNothing ($params->"distance")]) do={
		:set ($params->"distance") 10;
	}
	# local
	:local iid [$GetOrCreateEntity "/ip/route" $params Disabled=false];
	:return $iid;
}


:local package {
	"metaInfo"=$metaInfo;
	"getGateway"=$getGateway;
	"ensure"=$ensure;
}
:return $package;
