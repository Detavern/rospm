:local metaInfo {
    "name"="ip.firewall.address-list";
    "version"="0.3.0";
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
    :global findOneEnabledItem;
    :global findOneDisabledItem;
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
    :local idList [/ip firewall address-list find list=$List address=$pAddress !dynamic];
    # check there is same record or not 
    :if ([$IsEmpty $idList]) do={
        :set itemID [/ip firewall address-list add list=$List address=$pAddress];
        :return $itemID;
    } else {
        # find enabled one and return
        :set itemID [$findOneEnabledItem "/ip firewall address-list" $idList];
        :if (![$IsNil $itemID]) do={
            :return $itemID;
        }
        # find disabled one then enable it and return
        :set itemID [$findOneDisabledItem "/ip firewall address-list" $idList];
        :if (![$IsNil $itemID]) do={
            /ip firewall address-list enable $itemID;
            :return $itemID;
        }
        # unknown situation
        :error "ensureAddress: unknown situation";
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
        :local itemID [[$GetFunc "ip.firewall.address-list.ensureAddress"] List=$List Address=$addr];
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
