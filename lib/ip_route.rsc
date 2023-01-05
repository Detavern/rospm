#!rsc by RouterOS
# ===================================================================
# |       RSPM Packages      |   ip.route
# ===================================================================
# ALL package level functions follows lower camel case.
# 
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rspm/blob/master/LICENSE.md
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
# opt kwargs: RoutingMark=<str>
# opt kwargs: Distance=<num>
:local ensureStaticRoute do={
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
    :global helperAddByTemplate;
    :global findOneEnabled;
    :global findOneDisabled;
    :global helperSetByTemplate;
    # check params
    :if (![$IsStr $DstAddress]) do={
        :error "ensureStaticRoute: require \$DstAddress";
    }
    :if (![$IsStr $Gateway]) do={
        :error "ensureStaticRoute: require \$Gateway";
    }
    # read opt
    :local pDist [$ReadOption $Distance $TypeofNum];
    :local pRM [$ReadOption $RoutingMark $TypeofStr];
    # find if exist
    :local routeIDList;
    :if ([$IsNil $pRM]) do={
        :set routeIDList [/ip/route/find dst-address=$DstAddress !routing-mark !type];
    } else {
        :set routeIDList [/ip/route/find dst-address=$DstAddress routing-mark=$RoutingMark !type];
    }
    # if couldn't find matched then add one
    :if ([$IsEmpty $routeIDList]) do={
        :local template [$NewArray ];
        :set ($template->"dst-address") $DstAddress;
        :set ($template->"gateway") $Gateway;
        :set ($template->"routing-mark") $pRM;
        :set ($template->"distance") $pDist;
        :local idAdded [$helperAddByTemplate "/ip route" $template];
        :return $idAdded;
    } else {
        # first, find enabled one
        :local idEnabled [$findOneEnabled "/ip route" $routeIDList];
        :if (![$IsNil $idEnabled]) do={
            :local template [$NewArray ];
            :set ($template->"distance") $pDist;
            $helperSetByTemplate "/ip route" $idEnabled $template;
            :return $idEnabled;
        }
        # if no enabled one, then find a disabled one and enable it
        :local idDisabled [$findOneDisabled "/ip route" $routeIDList];
        :if (![$IsNil $idDisabled]) do={
            :local template [$NewArray ];
            :set ($template->"distance") $pDist;
            :set ($template->"disabled") "no";
            $helperSetByTemplate "/ip route" $idDisabled $template;
            :return $idDisabled;
        }
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
