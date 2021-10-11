#!rsc by RouterOS
# ===================================================================
# |       RSPM Packages      |   ip.route.rule
# ===================================================================
# ALL package level functions follows lower camel case.
# 
#
# Copyright (c) 2020-2021 detavern <detavern@live.com>
# https://github.com/Detavern/rspm/blob/master/LICENSE.md
#
:local metaInfo {
    "name"="ip.route.rule";
    "version"="0.3.1";
    "description"="";
};


# $ensureStaticRoute
# kwargs: DstAddress=<str>
# kwargs: Gateway=<str>
# opt kwargs: RoutingMark=<str>
# opt kwargs: Distance=<num>
:local ensureRule do={
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
    "ensureRule"=$ensureRule;
}
:return $package;
