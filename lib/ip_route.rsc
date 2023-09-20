#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   ip.route
# ===================================================================
# ALL package level functions follows lower camel case.
# 
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
    "name"="ip.route";
    "version"="0.4.0";
    "description"="";
};


# $getGateway
# kwargs: DstAddress=<str>
# kwargs: RoutingTable=<str>
# return: Gateway=<str>
:local getGateway do={
    #DEFINE global
    :global IsNil;
    :global IsEmpty;
    :global IsIPPrefix;
    :global Print;
    :global TypeofStr;
    :global ReadOption;
    # read opt
    :local pDstAddress [$ReadOption $DstAddress $TypeofStr];
    :local pRoutingTable [$ReadOption $RoutingTable $TypeofStr];
    # check params
    :if ([$IsNil $pDstAddress]) do={
        :error "getGateway: require \$DstAddress";
    }
    :if ([$IsNil $pRoutingTable]) do={
        :error "getGateway: require \$RoutingTable";
    }
    # check if has routing mark
    :local routeIDList [/ip/route/find dst-address=$pDstAddress active=yes routing-table=$pRoutingTable];
    :if ([$IsEmpty $routeIDList]) do={
        :error "getGateway: gateway for $pDstAddress with mark $pRoutingTable not found"
    }
    
    # check gateway like 1.1.1.1%ether1
    :local gw [:tostr [/ip/route/get ($routeIDList->0) gateway]];
    :local sPos [:find $gw "%"];
    :if ([$IsNil $sPos]) do={
        :return $gw;
    } else {
        :return [:pick $gw 0 $sPos];
    }
}


# $ensureStaticRoute
# kwargs: DstAddress=<str>
# kwargs: Gateway=<str>
# opt kwargs: RoutingTable=<str>
# opt kwargs: Distance=<num>
:local ensureStaticRoute do={
    #DEFINE global
    :global IsNil;
    :global IsStr;
    :global IsEmpty;
    :global TypeofNum;
    :global TypeofStr;
    :global NewArray;
    :global ReadOption;
    #DEFINE helper
    :global helperAddByTemplate;
    :global helperFindByTemplate;
    :global helperEnsureOneEnabled;
    # check params
    :if (![$IsStr $DstAddress]) do={
        :error "ensureStaticRoute: require \$DstAddress";
    }
    :if (![$IsStr $Gateway]) do={
        :error "ensureStaticRoute: require \$Gateway";
    }
    # read opt
    :local pDistance [$ReadOption $Distance $TypeofNum];
    :local pRoutingTable [$ReadOption $RoutingTable $TypeofStr];
    # set template
    :local tmpl [$NewArray ];
    :set ($tmpl->"dst-address") $DstAddress;
    :set ($tmpl->"gateway") $Gateway;
    :set ($tmpl->"routing-table") $pRoutingTable;
    if (![$IsNil pDistance]) do={
        :set ($tmpl->"distance") $pDistance;
    };
    # find if exist
    :local idList [$helperFindByTemplate "ip/route" $tmpl];
    :if ([$IsEmpty $idList]) do={
        # if couldn't find matched then add one
        [$helperAddByTemplate "/ip/route" $tmpl];
    } else {
        [$helperEnsureOneEnabled "/ip/route" $idList];
    }
}


# TODO: ensureBlackhole
:local ensureBlackhole do={}


# TODO: ensureProhibit
:local ensureProhibit do={}


# TODO: ensureUnreachable
:local ensureUnreachable do={}


:local package {
    "metaInfo"=$metaInfo;
    "getGateway"=$getGateway;
    "ensureStaticRoute"=$ensureStaticRoute;
    "ensureBlackhole"=$ensureBlackhole;
    "ensureProhibit"=$ensureProhibit;
    "ensureUnreachable"=$ensureUnreachable;
}
:return $package;
