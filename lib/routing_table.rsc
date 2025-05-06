#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   routing.table
# ===================================================================
# ALL package level functions follows lower camel case.
#
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="routing.table";
	"version"="0.6.0";
	"description"="";
};


# $add
# add a new routing table
# kwargs: Name=<str>            routing table name
# opt kwargs: FIB=<bool>        default false, forwarding Information Base
:local add do={
	#DEFINE global
	:global IsStr;
	:global IsEmpty;
	:global TypeofBool;
	:global ReadOption;
	# read option
	:local pFIB [$ReadOption $FIB $TypeofBool false];
	# check params
	:if (![$IsStr $Name]) do={
		:error "routing.table.add: require \$Name";
	}
	# add if not exist
	:local listIDList [/routing/table/find name=$Name];
	:if ([$IsEmpty $listIDList]) do={
		:if ($pFIB) do={
			/routing/table/add name=$Name fib;
		} else {
			/routing/table/add name=$Name;
		}
	} else {
		:error "routing.table.add: name $Name already exist";
	}
}


# $ensure
# kwargs: Name=<str>            routing table name
# opt kwargs: FIB=<bool>        default false, forwarding Information Base
:local ensure do={
	#DEFINE global
	:global IsStr;
	:global IsEmpty;
	:global TypeofBool;
	:global ReadOption;
	# read option
	:local pFIB [$ReadOption $FIB $TypeofBool false];
	# check params
	:if (![$IsStr $Name]) do={
		:error "routing.table.ensure: require \$Name";
	}
	# ensure Name
	:local listIDList [/routing/table/find name=$Name];
	:if ([$IsEmpty $listIDList]) do={
		:if ($pFIB) do={
			/routing/table/add name=$Name fib;
		} else {
			/routing/table/add name=$Name;
		}
	} else {
		:if ($pFIB) do={
			/routing/table/set $listIDList fib;
		} else {
			/routing/table/set $listIDList !fib;
		}
	}
}


:local package {
	"metaInfo"=$metaInfo;
	"add"=$add;
	"ensure"=$ensure;
}
:return $package;
