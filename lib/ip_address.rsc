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
    "version"="0.4.0";
    "description"="";
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


:local package {
    "metaInfo"=$metaInfo;
    "find"=$find;
}
:return $package;
