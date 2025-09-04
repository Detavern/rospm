#!rsc by RouterOS
# ===================================================================
# |     Global Functions     |   global-functions.network
# ===================================================================
# ALL global functions follows upper camel case.
# This package provides global functions for network calculations and CIDR parsing.
#
# Copyright (c) 2020-2025 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
# New structure
# <CIDR> array
# {
#     "cidr"="<ip-prefix>";
#     "ip"=<ip>;
#     "prefix"=<num>;
#     "subnet"=<ip>;
#     "wildcard"=<ip>;
#     "network"=<ip>;
#     "boardcast"=<ip>;
#     "first"=<ip>;
#     "last"=<ip>;
#     "total"=<num>;
#     "usable"=<num>;
# }
#
:local metaInfo {
	"name"="global-functions.network";
	"version"="0.7.0.a";
	"description"="This package provides global functions for network calculations and CIDR parsing.";
	"global"=true;
	"global-functions"={
		"ToIPPrefix";
		"IsCIDR";
		"ParseCIDR";
		"GetAddressRange";
	};
};


# $ToIPPrefix
# Convert string to ip-prefix. Return nil if not ip-prefix.
:global ToIPPrefix do={
	# global declare
	:global Nil;
	:global IsNil;
	:global IsStr;
	:global IsIPPrefix;
	# do
	:if ([$IsIPPrefix $1]) do={
		:return $1;
	}
	:if (![$IsStr $1]) do={
		:return $Nil;
	}
	:local v $1;
	:local pt "^([0-9]{1,3}\\.){3}[0-9]{1,3}\$";
	:local ptp "^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}\$";
	:if (!($v ~ $ptp)) do={
		:if ($v ~ $pt) do={
			:set v ("$v/32");
		} else {
			:return $Nil;
		}
	}
	:local result [[:parse ":return $v"]];
	:if (![$IsIPPrefix $result]) do={
		:return $Nil;
	}
	:return $result;
}


# $IsCIDR
# args: <var>                   <CIDR>
# return: <bool>                flag
:global IsCIDR do={
	# global declare
	:global IsArrayN;
	:global GetKeys;
	:global IsSubset;
	# check
	:if (![$IsArrayN $1]) do={
		:return false;
	};
	# check keys
	:local validator {
		"cidr";"ip";"prefix";"subnet";"wildcard";
		"network";"boardcast";"first";"last";"total";"usable";
	}
	:return [$IsSubset $validator [$GetKeys $1]];
}


# $ParseCIDR
# Parse a string, ipv4, ipv4 prefix into CIDR. Return nil if not CIDR.
# args: <var>                   ip, ip-prefix, str
# return: <CIDR> or nil         CIDR
:global ParseCIDR do={
	# global declare
	:global Nil;
	:global IsNil;
	:global IsStr;
	:global IsIP;
	:global IsIPPrefix;
	:global ToIPPrefix;
	:global RSplit;
	# local
	:local cidr $Nil;
	# parse cidr
	:if ([$IsIP $1]) do={
		:set cidr [$ToIPPrefix ("$1/32")];
	}
	:if ([$IsIPPrefix $1]) do={
		:set cidr $1;
	}
	:if ([$IsStr $1]) do={
		:set cidr [$ToIPPrefix $1];
	}
	:if ([$IsNil $cidr]) do={
		:return $Nil;
	}
	# parse property
	:local result {"cidr"=$cidr};
	:local splitted [$RSplit [:tostr $cidr] "/" 1];
	:set ($result->"ip") [:toip ($splitted->0)];
	:set ($result->"prefix") [:tonum ($splitted->1)];
	:set ($result->"subnet") (255.255.255.255<<(32 - ($result->"prefix")));
	:set ($result->"wildcard") (~($result->"subnet"));
	:set ($result->"network") (($result->"ip") & ($result->"subnet"));
	:set ($result->"broadcast") (($result->"ip") | ($result->"wildcard"));
	:set ($result->"first") (($result->"network") + 1 - (($result->"prefix") / 31));
	:set ($result->"last") (($result->"broadcast") - 1 + (($result->"prefix") / 31));
	:set ($result->"total") ([:tonum ($result->"wildcard")] + 1);
	:set ($result->"usable") (($result->"last") - ($result->"first") + 1);
	:return $result;
}


# $GetAddressRange
# Return a valid ip pool notation by specify a start offset & a pool length.
# args: <var>           cidr or ip-prefix or cidr-str
# args: <num>           start offset
# args: <num>           pool length
# return: <str>         ip pool notation like 192.168.0.100-192.168.0.199
:global GetAddressRange do={
	# global declare
	:global IsNil;
	:global IsCIDR;
	:global ParseCIDR;
	# check
	:local cidr $1;
	:if (![$IsCIDR $cidr]) do={
		:set cidr [$ParseCIDR $1];
		:if ([$IsNil $cidr]) do={
			:error "Global.Network.GetAddressRange: invalid CIDR input!";
		}
	};
	:local offset [:tonum $2];
	:local length [:tonum $3];
	:if (($cidr->"prefix") > 28) do={
		:error "Global.Network.GetAddressRange: CIDR prefix larger than /28!";
	}
	:if ($offset < 1 or $length < 1) do={
		:error "Global.Network.GetAddressRange: both \$2 and \$3 must be positive!";
	}
	:if (($offset + $length - 1) > ($cidr->"usable")) do={
		:error "Global.Network.GetAddressRange: range exceeds network boundaries!";
	}
	# do
	:local ipF (($cidr->"network") + $offset);
	:local ipL ($ipF + $length - 1);
	:return "$ipF-$ipL";
}


# package info
:local package {
	"metaInfo"=$metaInfo;
}
:return $package;

