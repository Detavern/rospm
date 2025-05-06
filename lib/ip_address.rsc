#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   ip.address
# ===================================================================
# ALL package level functions follows lower camel case.
#
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="ip.address";
	"version"="0.5.2";
	"description"="/ip/address utilities";
};


# $find
# opt kwargs: Interface=<str>                       find addresses by interface
# opt kwargs: InterfaceList=<str>                   find addresses by interface list
# opt kwargs: Output=<str>                          "cidr"=<str>, "ip"=<ip>(default)
# return: <array->str>                              list of addresses
:local find do={
	#DEFINE global
	:global IsStr;
	:global IsNothing;
	:global IsArray;
	:global IsEmpty;
	:global TypeofStr;
	:global NewArray;
	:global Split;
	:global ReadOption;
	:global GetFunc;
	#DEFINE helper
	:global helperFindByTemplate;
	# read opt
	:local intf [$ReadOption $Interface $TypeofStr ""];
	:local intfL [$ReadOption $InterfaceList $TypeofStr ""];
	:local pOutput [$ReadOption $Output $TypeofStr "ip"];
	# local
	:local intfList;
	:if ($intf != "") do={
		:set intfList {$intf};
	}
	:if ($intfL != "") do={
		:set intfList [[$GetFunc "interface.list.findMembers"] Name=$intfL Enabled=true];
	}
	:if ([$IsNothing $intfList]) do={
		:error "ip.address.find: one of \$Interface, \$InterfaceList needed";
	}
	# find address by interface name list
	:local addressList [$NewArray ];
	:local template [$NewArray ];
	:set ($template->"disabled") no;
	:foreach v in $intfList do={
		:set ($template->"interface") $v;
		:local addrList [$helperFindByTemplate "/ip/address" $template Output="address"];
		:set addressList ($addressList, $addrList);
	}
	:if ($pOutput = "ip") do={
		:local splitted [$NewArray ];
		:foreach v in $addressList do={
			:local ipAddr [:toip ([$Split $v "/" 1]->0)];
			:set ($splitted->[:len $splitted]) $ipAddr;
		}
		:return $splitted;
	} else {
		:return $addressList;
	}
}


# $waitAndFind
# opt kwargs: Interface=<str>                       find addresses by interface
# opt kwargs: InterfaceList=<str>                   find addresses by interface list
# opt kwargs: Output=<str>                          "cidr"=<str>, "ip"=<ip>(default)
# opt kwargs: Timeout=<time>                        timeout(sec)
# return: <array->str>                              list of addresses
:local waitAndFind do={
	#DEFINE global
	:global Nil;
	:global TypeofTime;
	:global ReadOption;
	:global GetFunc;
	# check
	:local timeout [$ReadOption $Timeout $TypeofTime 0:0:3]
	:if ($timeout > 0:3:0) do={
		:error "ip.address.waitAndFind: Timeout should be lower than 3 minutes!";
	}
	# local
	:local ipList $Nil;
	:local continueFlag true;
	:local cnt 0:0:0;
	:while ($continueFlag) do={
		:set ipList [[$GetFunc "ip.address.find"] Interface=$Interface InterfaceList=$InterfaceList];
		:if ([:len $ipList]=0) do={
			:put ("ip.address.waitAndFind: could not find address by condition: " . \
				"<Interface=$Interface List=$InterfaceList>, waiting...");
			:delay 1000ms;
			:set cnt ($cnt + 0:0:1);
		} else {
			:set continueFlag false;
		}
		# break
		:if ($cnt >= $timeout) do={
			:put "ip.address.waitAndFind: timeout $timeout second(s) reached!";
			:set continueFlag false;
		}
	};
	:return $ipList;
}


:local package {
	"metaInfo"=$metaInfo;
	"find"=$find;
	"waitAndFind"=$waitAndFind;
}
:return $package;
