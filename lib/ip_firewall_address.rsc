#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   ip.firewall.address
# ===================================================================
# ALL package level functions follows lower camel case.
# This package provides utilities for managing firewall address lists in RouterOS.
#
# Copyright (c) 2020-2025 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="ip.firewall.address";
	"version"="0.7.0.a";
	"description"="This package provides utilities for managing firewall address lists in RouterOS.";
};


# $ensureAddress
# kwargs: List=<str>                        address list name
# kwargs: Address=<str>|<ip>|<ip-prefix>    ip or ip-prefix or FQDN
# return: <id>
:local ensureAddress do={
	#DEFINE global
	:global IsNil;
	:global IsIP;
	:global IsIPPrefix;
	:global IsStr;
	:global IsEmpty;
	#DEFINE helper
	:global helperEnsureOneEnabled;
	# check params
	:if (![$IsStr $List]) do={
		:error "ensureAddress: require \$List";
	}
	:local pAddress;
	:if ([$IsIP $Address] or [$IsIPPrefix $Address] or [$IsStr $Address]) do={
		:set pAddress [:tostr $Address];
	} else {
		:error "ensureAddress: require \$Address";
	}
	# find
	:local itemID;
	:local idList [/ip/firewall/address-list/find list=$List address=$pAddress !dynamic];
	# check there is same record or not
	:if ([$IsEmpty $idList]) do={
		:set itemID [/ip/firewall/address-list/add list=$List address=$pAddress];
		:return $itemID;
	} else {
		$helperEnsureOneEnabled "/ip/firewall/address-list" $idList;
	}
}


# $ensureAddressList
# kwargs: List=<str>                    address list name
# kwargs: AddressList=<str>|<ip>        list of ip or cidr or FQDN
# return: ID=<id>
:local ensureAddressList do={
	#DEFINE global
	:global IsNil;
	:global IsStr;
	:global IsArray;
	:global NewArray;
	:global GetFunc;
	# check params
	:if (![$IsStr $List]) do={
		:error "ensureAddressList: require \$List";
	}
	:if (![$IsArray $AddressList]) do={
		:error "ensureAddressList: require \$AddressList";
	}
	# iter
	:local idList [$NewArray ];
	:foreach addr in $AddressList do={
		:local itemID [[$GetFunc "ip.firewall.address.ensureAddress"] List=$List Address=$addr];
		:set ($idList->[:len $idList]) $itemID;
	}
	:return $idList;
}


:local package {
	"metaInfo"=$metaInfo;
	"ensureAddress"=$ensureAddress;
	"ensureAddressList"=$ensureAddressList;
}
:return $package;
