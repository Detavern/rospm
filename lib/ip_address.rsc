:local metaInfo {
    "name"="ip.address";
    "version"="0.0.1";
    "description"="";
};


# $find
# opt kwargs: Interface=<str>                       find addresses by interface name
# opt kwargs: InterfaceList=<array->str>|<str>      find addresses by interface list name or interface array
# opt kwargs: Output=<str>                          "cidr"=<str>, "ip"=<ip>(default)
# return: <array->str>                              list of addresses
:global find do={
    #DEFINE global
    :global IsStr;
    :global IsNothing;
    :global IsArray;
    :global IsEmpty;
    :global TypeofStr;
    :global TypeofArray;
    :global NewArray;
    :global Split;
    :global Appends;
    :global ReadOption;
    :global GetFunc;
    #DEFINE helper
    :global findAllItemsByTemplate;
    # read opt
    :local intf [$ReadOption $Interface $TypeofStr];
    :local intfL [$ReadOption $InterfaceList $TypeofArray];
    :local pOutput [$ReadOption $Output $TypeofStr "ip"];
    # local
    :local intfList;
    :if ([$IsStr $intf] and ($intf != "")) do={
        :set intfList {$intf};
    }
    :if ([$IsStr $intfL]) do={
        :set intfList [[$GetFunc "interface.list.findMembers"] Name=$intfL Enabled=true];
    }
    :if ([$IsArray $intfL]) do={
        :set intfList $intfL;
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
        :local addrList [$findAllItemsByTemplate "/ip address" $template Output="address"];
        :set addressList ($addressList, $addrList);
    }
    :if ($pOutput = "ip") do={
        :local splitted [$NewArray ];
        :foreach v in $addressList do={
            :local ipAddr [:toip ([$Split $v "/" 1]->0)];
            [$Appends $splitted $ipAddr];
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
