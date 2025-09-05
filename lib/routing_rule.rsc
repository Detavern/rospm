#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   routing.rule
# ===================================================================
# ALL package level functions follows lower camel case.
# This package offers tools for managing and ensuring routing rules in RouterOS.
#
# Copyright (c) 2020-2025 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="routing.rule";
	"version"="0.7.0";
	"description"="This package offers tools for managing and ensuring routing rules in RouterOS.";
	"essential"=false;
	"global"=false;
};


# $ensure
# kwargs: Params=<params>
# params:
#   opt kwargs: comment=<str>
#   opt kwargs: src-address=<str>
#   opt kwargs: dst-address=<str>
#   opt kwargs: routing-mark=<str>
#   opt kwargs: interface=<str>
#   opt kwargs: action=<str>
#   opt kwargs: table=<str>
:local ensure do={
	#DEFINE global
	:global IsNil;
	:global IsEmpty;
	:global TypeofArray;
	:global TypeofStr;
	:global ReadOption;
	:global GetOrCreateEntity;
	# read params
	:local params [$ReadOption $Params $TypeofArray];
	:if ([$IsNil $params]) do={:error "routing.rule.ensure: require \$Params"}
	:if ([$IsEmpty $params]) do={:error "routing.rule.ensure: require options in \$Params"}
	# local
	:local iid [$GetOrCreateEntity "/routing/rule" $params Disabled=false];
	:return $iid;
}


# $ensureReserved
:local ensureReserved do={
	#DEFINE global
	:global IsEmpty;
	# local
	:local prefix "ENSURE RESERVED";
	# clean
	/routing/rule/remove [/routing/rule/find comment~$prefix];
	# check
	:local idList [/ip/firewall/address-list/find list="IP-CIDR_RESERVED"];
	:if ([$IsEmpty $idList]) do={
		:error "routing.rule.ensureReserved: IP-CIDR_RESERVED not found";
	}
	# add
	:foreach v in $idList do={
		:local addr [/ip/firewall/address-list/get number=$v address];
		/routing/rule/add dst-address=$addr action=lookup table=main comment="$prefix";
	}
}


:local package {
	"metaInfo"=$metaInfo;
	"ensure"=$ensure;
	"ensureReserved"=$ensureReserved;
}
:return $package;
