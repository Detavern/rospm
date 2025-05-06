#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   ip.firewall.raw
# ===================================================================
# ALL package level functions follows lower camel case.
#
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="ip.firewall.raw";
	"version"="0.6.0";
	"description"="";
};


# $ensureStaticRoute
# kwargs: DstAddress=<str>
# kwargs: Gateway=<str>
# opt kwargs: RoutingMark=<str>
# opt kwargs: Distance=<num>
:local ensureRule do={
	#DEFINE global
	:global Nil;
	:global IsNil;
	:global IsStr;
	:global IsEmpty;
	:global IsNum;
	:global TypeofNum;
	:global TypeofStr;
	:global NewArray;
	:global Print;
	:global ReadOption;
	#DEFINE helper
	:global helperAddByTemplate;
	:global findOneEnabled;
	:global findOneDisabled;
	:global helperSetByTemplate;
	# check params
	:if (![$IsStr $DstAddress]) do={
		:error "ensureStaticRoute: require \$DstAddress";
	}

}


:local package {
	"metaInfo"=$metaInfo;
	"ensureRule"=$ensureRule;
}
:return $package;
