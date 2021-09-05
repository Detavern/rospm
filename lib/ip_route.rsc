:local metaInfo {
    "name"="ip.route";
    "version"="0.1.1";
    "description"="";
};


# $getGateway
# kwargs: DstAddress=<str>
# kwargs: RoutingMark=<str>
# return: Gateway=<str>
:global getGateway do={
    #DEFINE global
    :global IsNil;
    :global IsNothing;
    :global IsStr;
    :global IsEmpty;
    :global IsIPPrefix;
    # check params
    :if (![$IsStr $DstAddress]) do={
        :error "getGateway: require \$DstAddress";
    }
    # HACK: don't know why ':set RoutingMark "";' get error without following line.
    $IsNothing $RoutingMark;
    :if ([$IsNothing $RoutingMark]) do={
        :set RoutingMark "";
    }
    :if (![$IsStr $RoutingMark]) do={
        :error "getGateway: require \$RoutingMark";
    }
    # check if has routing mark
    :local routeIDList;
    :if ($RoutingMark="") do={
        :set routeIDList [/ip route find dst-address=$DstAddress active=yes !routing-mark !type];
        :if ([$IsEmpty $routeIDList]) do={
            :error "getGateway: gateway for $DstAddress not found"
        }
    } else {
        :set routeIDList [/ip route find dst-address=$DstAddress active=yes routing-mark=$RoutingMark !type];
        :if ([$IsEmpty $routeIDList]) do={
            :error "getGateway: gateway for $DstAddress with mark $RoutingMark not found"
        }
    }
    # check gateway like 1.1.1.1%ether1
    :local gw ([/ip route get ($routeIDList->0) gateway]->0);
    :local sPos [:find $gw "%"];
    :if ([$IsEmpty $sPos]) do={
        :return [:pick $gw 0 $sPos];
    } else {
        :return $gw;
    }
}


# $ensureStaticRoute
# kwargs: DstAddress=<str>
# kwargs: Gateway=<str>
# opt kwargs: RoutingMark=<str>
# opt kwargs: Distance=<num>
:global ensureStaticRoute do={
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
    :if (![$IsStr $Gateway]) do={
        :error "ensureStaticRoute: require \$Gateway";
    }
    # read opt
    :local pDist [$ReadOption $Distance $TypeofNum];
    :local pRM [$ReadOption $RoutingMark $TypeofStr];
    # find if exist
    :local routeIDList;
    :if ([$IsNil $pRM]) do={
        :set routeIDList [/ip route find dst-address=$DstAddress !routing-mark !type];
    } else {
        :set routeIDList [/ip route find dst-address=$DstAddress routing-mark=$RoutingMark !type];
    }
    # if couldn't find matched then add one
    :if ([$IsEmpty $routeIDList]) do={
        :local template [$NewArray ];
        :set ($template->"dst-address") $DstAddress;
        :set ($template->"gateway") $Gateway;
        :set ($template->"routing-mark") $pRM;
        :set ($template->"distance") $pDist;
        :local idAdded [$addItemByTemplate "/ip route" $template];
        :return $idAdded;
    } else {
        # first, find enabled one
        :local idEnabled [$findOneEnabledItem "/ip route" $routeIDList];
        :if (![$IsNil $idEnabled]) do={
            :local template [$NewArray ];
            :set ($template->"distance") $pDist;
            $setItemAttrByTemplate "/ip route" $idEnabled $template;
            :return $idEnabled;
        }
        # if no enabled one, then find a disabled one and enable it
        :local idDisabled [$findOneDisabledItem "/ip route" $routeIDList];
        :if (![$IsNil $idDisabled]) do={
            :local template [$NewArray ];
            :set ($template->"distance") $pDist;
            :set ($template->"disabled") "no";
            $setItemAttrByTemplate "/ip route" $idDisabled $template;
            :return $idDisabled;
        }
    }
}

# TODO: ensureBlackhole


:local package {
    "metaInfo"=$metaInfo;
    "getGateway"=$getGateway;
    "ensureStaticRoute"=$ensureStaticRoute;
    "ensureBlackhole"=$ensureBlackhole;
    "ensureProhibit"=$ensureProhibit;
    "ensureUnreachable"=$ensureUnreachable;
}
:return $package;
