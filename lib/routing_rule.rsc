#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   routing.rule
# ===================================================================
# ALL package level functions follows lower camel case.
# routing rule tools
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="routing.rule";
	"version"="0.6.0";
	"description"="routing rule tools";
};


# $ensure
# opt kwargs: SrcAddress=<str>
# opt kwargs: DstAddress=<str>
# opt kwargs: RoutingMark=<str>
# opt kwargs: Interface=<str>
# opt kwargs: Action=<str>
# opt kwargs: Table=<str>
:local ensure do={
	#DEFINE global
	:global Nil;
	:global IsNil;
	:global IsEmpty;
	:global TypeofStr;
	:global NewArray;
	:global ReadOption;
	#DEFINE helper
	:global helperAddByTemplate;
	:global helperFindByTemplate;
	:global findOneEnabled;
	:global findOneDisabled;
	# read option
	:local pSrcAddress [$ReadOption $SrcAddress $TypeofStr];
	:local pDstAddress [$ReadOption $DstAddress $TypeofStr];
	:local pRoutingMark [$ReadOption $RoutingMark $TypeofStr];
	:local pInterface [$ReadOption $Interface $TypeofStr];
	:local pAction [$ReadOption $Action $TypeofStr];
	:local pTable [$ReadOption $Table $TypeofStr];
	# local
	:local tmpl [$NewArray ];
	:set ($tmpl->"src-address") $pSrcAddress;
	:set ($tmpl->"dst-address") $pDstAddress;
	:set ($tmpl->"routing-mark") $pRoutingMark;
	:set ($tmpl->"interface") $pInterface;
	:set ($tmpl->"action") $pAction;
	:set ($tmpl->"table") $pTable;
	# find
	:local idList [$helperFindByTemplate "/routing/rule" $tmpl];
	:if ([$IsEmpty $idList]) do={
		[$helperAddByTemplate "/routing/rule" $tmpl];
		:return $Nil;
	}
	:local disableID [$findOneDisabled "/routing/rule" $idList];
	:if (![$IsNil $disableID]) do={
		/routing/rule/enable numbers=$disableID;
		:return $Nil;
	}
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
