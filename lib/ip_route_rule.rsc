:local metaInfo {
    "name"="ip.route.rule";
    "version"="0.1.1";
    "description"="";
};


# $ensureStaticRoute
# kwargs: DstAddress=<str>
# kwargs: Gateway=<str>
# opt kwargs: RoutingMark=<str>
# opt kwargs: Distance=<num>
:global ensureRule do={
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
    :global addItemByTemplate;
    :global findOneEnabledItem;
    :global findOneDisabledItem;
    :global setItemAttrByTemplate;
    # check params
    :if (![$IsStr $DstAddress]) do={
        :error "ensureStaticRoute: require \$DstAddress";
    }
  
}


:local package {
    "metaInfo"=$metaInfo;
    "getGateway"=$getGateway;
}
:return $package;
