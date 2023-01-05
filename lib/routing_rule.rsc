#!rsc by RouterOS
# ===================================================================
# |       RSPM Packages      |   routing.rule
# ===================================================================
# ALL package level functions follows lower camel case.
# routing rule tools
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rspm/blob/master/LICENSE.md
#
:local metaInfo {
    "name"="routing.rule";
    "version"="0.4.0";
    "description"="routing rule tools";
};


# $ensure
# opt kwargs: SrcAddress=<str>
# opt kwargs: DstAddress=<str>
# opt kwargs: RoutingMark=<str>
# opt kwargs: Interface=<str>
# opt kwargs: Action=<str>
# opt kwargs: Table=<str>
:local ensure do={
    #DEFINE global
    :global IsNil;
    :global TypeofStr;
    :global NewArray;
    :global ReadOption;
    #DEFINE helper
    :global helperAddByTemplate;
    :global helperFindByTemplate;
    :global findOneEnabled;
    :global findOneDisabled;
    # read option
    :local pSrcAddress [$ReadOption $SrcAddress $TypeofStr];
    :local pDstAddress [$ReadOption $DstAddress $TypeofStr];
    :local pRoutingMark [$ReadOption $RoutingMark $TypeofStr];
    :local pInterface [$ReadOption $Interface $TypeofStr];
    :local pAction [$ReadOption $Action $TypeofStr];
    :local pTable [$ReadOption $Table $TypeofStr];
    # local
    :local tmpl [$NewArray ];
    :set ($tmpl->"src-address") $pSrcAddress;
    :set ($tmpl->"dst-address") $pDstAddress;
    :set ($tmpl->"routing-mark") $pRoutingMark;
    :set ($tmpl->"interface") $pInterface;
    :set ($tmpl->"action") $pAction;
    :set ($tmpl->"table") $pTable;
    # find
    :local idList [$helperFindByTemplate "/routing/rule" $tmpl];
    :local disableID [$findOneDisabled "/routing/rule" $idList];
    :if (![$IsNil $disableID]) do={
        /routing/rule/enable numbers=$disableID;
    } else {
        [$helperAddByTemplate "/routing/rule" $tmpl];
    }
}


:local package {
    "metaInfo"=$metaInfo;
    "ensure"=$ensure;
}
:return $package;