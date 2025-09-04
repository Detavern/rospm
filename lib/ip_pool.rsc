#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   ip.pool
# ===================================================================
# ALL package level functions follows lower camel case.
# This package provides functions to manage IP address pools.
#
# Copyright (c) 2020-2025 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="ip.pool";
	"version"="0.7.0.a";
	"description"="This package provides functions to manage IP address pools.";
};


# $ensure
# Ensure the target interface has a DHCP server, leave it disabled if already disabled.
# If address pool does not exist, it will be created automatically.
# kwargs: Params=<params>
# params:
#   kwargs: Name=<str>
#   opt kwargs: ranges=<str>
#   opt kwargs: next-pool=<str>
#   opt kwargs: network=<ip-prefix>, use with <range-offset> and <range-count> together
#   opt kwargs: range-offset=<num>, default is 100
#   opt kwargs: range-count=<num>, default is 100
:local ensure do={
	#DEFINE global
	:global IsNil;
	:global IsEmpty;
	:global IsNothing;
	:global TypeofArray;
	:global TypeofStr;
	:global TypeofNum;
	:global TypeofIPPrefix;
	:global ReadOption;
	:global GetAddressRange;
	:global GetOrCreateEntity;
	# read params
	:local params [$ReadOption $Params $TypeofArray];
	:if ([$IsNil $params]) do={:error "ip.pool.ensure: require \$Params"}
	:if ([$IsEmpty $params]) do={:error "ip.pool.ensure: require options in \$Params"}
	# read opt
	:local pName [$ReadOption ($params->"name") $TypeofStr];
	:if ([$IsNil $pName]) do={:error "ip.pool.ensure: require name in \$Params"}
	:local pRanges [$ReadOption ($params->"ranges") $TypeofStr];
	# use ranges
	:if (![$IsNil $pRanges]) do={
		:local iid [$GetOrCreateEntity "/ip/pool" $params Filter=({"name"=$pName})];
		:return $iid;
	}
	# use network
	:local pNetwork [$ReadOption ($params->"network") $TypeofIPPrefix];
	:set ($params->"network");
	:if ([$IsNil $pNetwork]) do={
		:error "ip.pool.ensure: require either ranges or network in \$Params"
	}
	# offset & count
	:local rOffset [$ReadOption ($params->"range-offset") $TypeofNum 100];
	:local rCount [$ReadOption ($params->"range-count") $TypeofNum 100];
	:set ($params->"range-offset");
	:set ($params->"range-count");
	:local ranges [$GetAddressRange $pNetwork $rOffset $rCount];
	:set ($params->"ranges") $ranges;
	:local iid [$GetOrCreateEntity "/ip/pool" $params Filter=({"name"=$pName})];
	:return $iid;
}


:local package {
	"metaInfo"=$metaInfo;
	"ensure"=$ensure;
}
:return $package;
