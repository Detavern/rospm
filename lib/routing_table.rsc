#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   routing.table
# ===================================================================
# ALL package level functions follows lower camel case.
# This package provides functions to manage and ensure routing tables on the device.
#
# Copyright (c) 2020-2025 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="routing.table";
	"version"="0.7.0.a";
	"description"="This package provides functions to manage and ensure routing tables on the device.";
};


# $ensure
# kwargs: Params=<params>
# params:
#   opt kwargs: comment=<str>
#   opt kwargs: name=<str>
#   opt kwargs: !fib=<bool>
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
	:if ([$IsNil $params]) do={:error "routing.table.ensure: require \$Params"}
	:if ([$IsEmpty $params]) do={:error "routing.table.ensure: require options in \$Params"}
	# read opt
	:local pName [$ReadOption ($params->"name") $TypeofStr];
	:if ([$IsNil $pName]) do={:error "routing.table.ensure: require name in \$Params"}
	:if ($pName="main") do={
		:return [/routing/table/find name="main"];
	}
	:if ([$IsNothing ($params->"!fib")]) do={
		:set ($params->"!fib") false;
	}
	# local
	:local iid [$GetOrCreateEntity "/routing/table" \
		$params Filter=({"name"=$pName}) Disabled=false];
	:return $iid;
}


:local package {
	"metaInfo"=$metaInfo;
	"ensure"=$ensure;
}
:return $package;
