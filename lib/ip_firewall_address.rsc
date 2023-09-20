#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   ip.firewall.address
# ===================================================================
# ALL package level functions follows lower camel case.
# 
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
    "name"="ip.firewall.address";
    "version"="0.5.0";
    "description"="";
};


# $ensureAddress
# kwargs: List=<str>                    address list name
# kwargs: Address=<str>|<ip>            ip or cidr or FQDN
# return: <id>
:local ensureAddress do={
    #DEFINE global
    :global IsNil;
    :global IsIP;
    :global IsStr;
    :global IsEmpty;
    #DEFINE helper
    :global helperEnsureOneEnabled;
    # check params
    :if (![$IsStr $List]) do={
        :error "ensureAddress: require \$List";
    }
    :local pAddress;
    :if ([$IsIP $Address] or [$IsStr $Address]) do={
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
    :global Nil;
    :global IsNil;
    :global IsArray;
    :global IsStr;
    :global Append;
    :global NewArray;
    :global Print;
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
        :set idList [$Append $idList $itemID];
    }
    :return $idList;
}


:local package {
    "metaInfo"=$metaInfo;
    "ensureAddress"=$ensureAddress;
    "ensureAddressList"=$ensureAddressList;
}
:return $package;
