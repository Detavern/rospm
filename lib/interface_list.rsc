#!rsc by RouterOS
# ===================================================================
# |       RSPM Packages      |   interface.list
# ===================================================================
# ALL package level functions follows lower camel case.
# 
#
# Copyright (c) 2020-2021 detavern <detavern@live.com>
# https://github.com/Detavern/rspm/blob/master/LICENSE.md
#
:local metaInfo {
    "name"="interface.list";
    "version"="0.3.1";
    "description"="";
};


# $add
# add a new interface list
# kwargs: Name=<str>            new interface list name
:local add do={
    #DEFINE global
    :global IsStr;
    :global IsEmpty;
    # check params
    :if (![$IsStr $Name]) do={
        :error "interface.list.add: require \$Name";
    }
    # add if not exist
    :local listIDList [/interface/list/find name=$Name];
    :if ([$IsEmpty $listIDList]) do={
        /interface/list/add name=$Name;
    } else {
        :error "interface.list.add: list name $Name already exist";
    }
}


# $ensure
# kwargs: Name=<str>            ensure a list name is exist
:local ensure do={
    #DEFINE global
    :global IsStr;
    :global IsEmpty;
    # check params
    :if (![$IsStr $Name]) do={
        :error "interface.list.ensure: require \$Name";
    }
    # ensure Name
    :local listIDList [/interface/list/find name=$Name];
    :if ([$IsEmpty $listIDList]) do={
        /interface/list/add name=$Name;
    }
}


# $ensureInclude
# ensure target list's include list
# kwargs: Name=<str>                target list name
# kwargs: List=<array->str>         list of included list name
:local ensureInclude do={
    #DEFINE global
    :global IsStr;
    :global IsArray;
    :global IsEmpty;
    :global Append;
    :global UniqueArray;
    # check params
    :if (![$IsStr $Name]) do={
        :error "interface.list.ensureInclude: require \$Name";
    }
    :if (![$IsArray $List]) do={
        :error "interface.list.ensureInclude: require \$List";
    }
    # check list's existance
    :local idList [/interface/list/find name=$Name];
    :if ([$IsEmpty $idList]) do={
        :error "interface.list.ensureInclude: interface list name $Name not found";
    }
    :local itemID ($idList->0);
    :foreach v in $List do={
        :local vIDList [/interface/list/find name=$v];
        :if ([$IsEmpty $vIDList]) do={
            :error "interface.list.ensureInclude: interface list name $v in \$List not found";
        }
    }
    # get current include
    :local srcIncludeList [/interface/list/get number=$itemID "include"];
    :local mergedList [$UniqueArray [$Append $srcIncludeList $List]];
    # set it
    /interface/list/set numbers=$itemID include=$mergedList;
}


# $ensureExclude
# ensure target list's exclude list
# kwargs: Name=<str>                target list name
# kwargs: List=<array->str>         list of excluded list name
:local ensureExclude do={
    #DEFINE global
    :global IsStr;
    :global IsArray;
    :global IsEmpty;
    :global Append;
    :global UniqueArray;
    # check params
    :if (![$IsStr $Name]) do={
        :error "interface.list.ensureExclude: require \$Name";
    }
    :if (![$IsArray $List]) do={
        :error "interface.list.ensureExclude: require \$List";
    }
    # check list's existance
    :local idList [/interface/list/find name=$Name];
    :if ([$IsEmpty $idList]) do={
        :error "interface.list.ensureExclude: interface list name $Name not found";
    }
    :local itemID ($idList->0);
    :foreach v in $List do={
        :local vIDList [/interface/list/find name=$v];
        :if ([$IsEmpty $vIDList]) do={
            :error "interface.list.ensureExclude: interface list name $v in \$List not found";
        } 
    }
    # get current include
    :local srcExcludeList [/interface/list/get number=$itemID "include"];
    :local mergedList [$UniqueArray [$Append $srcExcludeList $List]];
    # set it
    /interface/list/set numbers=$itemID include=$mergedList;
}


# $addMembers
# Add interfaces into interface list
# will raise error when add already exist interface
# kwargs: Name=<str>                target list name
# kwargs: List=<array->str>         list of interface name
:local addMembers do={
    #DEFINE global
    :global IsStr;
    :global IsArray;
    :global IsEmpty;
    # check params
    :if (![$IsStr $Name]) do={
        :error "interface.list.addMembers: require \$Name";
    }
    :if (![$IsArray $List]) do={
        :error "interface.list.addMembers: require \$List";
    }
    # check list's existance
    :local idList [/interface/list/find name=$Name];
    :if ([$IsEmpty $idList]) do={
        :error "interface.list.addMembers: interface list name $Name not found";
    }
    :local itemID ($idList->0);
    :foreach v in $List do={
        # NOTE: different ros version may infect this
        :local vIDList [/interface/find name=$v !dynamic];
        :if ([$IsEmpty $vIDList]) do={
            :error "interface.list.addMembers: static interface name $v not found";
        } 
    }
    # add membership
    :foreach v in $List do={
        /interface/list/member/add interface=$v list=$Name;
    }
}


# $ensureMembers
# kwargs: Name=<str>                target list name
# kwargs: List=<array->str>         list of interface name
:local ensureMembers do={
    #DEFINE global
    :global IsStr;
    :global IsArray;
    :global IsEmpty;
    #DEFINE helper
    :global itemsFoundEnsureOneEnabled;
    # check params
    :if (![$IsStr $Name]) do={
        :error "interface.list.ensureMembers: require \$Name";
    }
    :if (![$IsArray $List]) do={
        :error "interface.list.ensureMembers: require \$List";
    }
    # check list's existance
    :local idList [/interface/list/find name=$Name];
    :if ([$IsEmpty $idList]) do={
        :error "interface.list.ensureMembers: interface list name $Name not found";
    }
    :local itemID ($idList->0);
    :foreach v in $List do={
        # NOTE: different ros version may infect this
        :local vIDList [/interface/find name=$v !dynamic];
        :if ([$IsEmpty $vIDList]) do={
            :error "interface.list.ensureMembers: static interface name $v not found";
        } 
    }
    # ensure membership
    :foreach v in $List do={
        :local vIDList [/interface/list/member/find interface=$v list=$Name];
        :if ([$IsEmpty $vIDList]) do={
            /interface/list/member/add interface=$v list=$Name;
        } else {
            $itemsFoundEnsureOneEnabled "/interface/list/member" $vIDList;
        }
    }
}


# $setMembersAttrs
# TODO: set all interfaces' attribute of certain list
# kwargs: Name=<str>                target list name
# kwargs: Attrs=<array->str>        array of attributes
:local setMembersAttrs do={
}


# $findMembers
# find all interface by list name
# kwargs: Name=<str>                target list name
# opt kwargs: Enabled=<bool>        false(default), find enabled interface only if true
:local findMembers do={
    #DEFINE global
    :global IsStr;
    :global IsEmpty;
    :global NewArray;
    :global UniqueArray;
    :global ReadOption;
    :global TypeofBool;
    :global findAllItemsByTemplate;
    # check params
    :if (![$IsStr $Name]) do={
        :error "interface.list.findMembers: require \$Name";
    }
    :local intfIDList [/interface/list/find name=$Name !disabled];
    :if ([$IsEmpty $intfIDList]) do={
        :error "interface.list.findMembers: specific \$Name not exist or disabled"
    }
    :local pEnabled [$ReadOption $Enabled $TypeofBool false];
    # find list itself
    :local template [$NewArray];
    :set ($template->"list") $Name;
    :if ($pEnabled) do={
        :set ($template->"disabled") no;
    }
    :local nameList [$findAllItemsByTemplate "/interface/list/member" $template Output="interface"];
    # find in include
    :local includeList [/interface/list/get ($intfIDList->0) include];
    :foreach listName in $includeList do={
        :set ($template->"list") $listName;
        :local nList [$findAllItemsByTemplate "/interface/list/member" $template Output="interface"];
        :set nameList ($nameList, $nList);
    }
    :return [$UniqueArray $nameList];
}



:local package {
    "metaInfo"=$metaInfo;
    "add"=$add;
    "ensure"=$ensure;
    "ensureInclude"=$ensureInclude;
    "ensureExclude"=$ensureExclude;
    "addMembers"=$addMembers;
    "ensureMembers"=$ensureMembers;
    "setMembersAttrs"=$setMembersAttrs;
    "findMembers"=$findMembers;
}
:return $package;
