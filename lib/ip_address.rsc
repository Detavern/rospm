:local metaInfo {
    "name"="ip.address";
    "version"="0.0.1";
    "description"="";
};


# $findAllAddress
# opt kwargs: Interface=<str>
# opt kwargs: InterfaceList=<array->str>|<str>
# opt kwargs: Output=<str>                          "cidr", "ip"
# return: <array->str>                              list of address(cidr format)
:global findAllAddress do={
    #DEFINE global
    :global IsNil;
    :global IsNothing;
    :global IsArray;
    :global IsEmpty;
    :global TypeofStr;
    :global TypeofArray;
    :global NewArray;
    :global Print;
    :global Split;
    :global Append;
    :global ReadOption;
    :global GetFunc;
    #DEFINE helper
    :global findAllItemsByTemplate;
    # read opt
    :local intf [$ReadOption $Interface $TypeofStr];
    # REVIEW: type mismatch
    :local intfL [$ReadOption $InterfaceList $TypeofArray];
    :local pOutput [$ReadOption $Output $TypeofStr "ip"];
    # local
    :local intfList;
    :if (![$IsNil $intf]) do={
        :set intfList {$intf};
    }
    :if (![$IsNil $intfL]) do={
        :if ([$IsArray $intfL]) do={
            :set intfList $intfL;
        } else {
            :set intfList [[$GetFunc "interface.list.findMembers"] Name=$intfL Enabled=true];
        }
    }
    :if ([$IsNothing $intfList]) do={
        :error "findAllAddress: one of \$Interface, \$InterfaceList needed"
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
            :set splitted [$Append $splitted $ipAddr];
        }
        :return $splitted;
    } else {
        :return $addressList;
    }
}


:local package {
    "metaInfo"=$metaInfo;
    "findAllAddress"=$findAllAddress;
}
:return $package;
