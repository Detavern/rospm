:local metaInfo {
    "name"="interface.list";
    "version"="0.0.1";
    "description"="";
};


# $addList
# kwargs: iName=<str>
:local addList do={
    #DEFINE global
    :global IsStr;
    :global IsEmpty;
    # check params
    :if (![$IsStr $iName]) do={
        :error "addList: require \$iName";
    }
    # add if not exist
    :local listIDList [/interface list find name=$iName];
    :if ([$IsEmpty $listIDList]) do={
        /interface list add name=$iName;
    } else {
        :error "addList: list name $iName already exist";
    }
}


# $ensureList
# kwargs: iName=<str>
:local ensureList do={
    #DEFINE global
    :global IsStr;
    :global IsEmpty;
    # check params
    :if (![$IsStr $iName]) do={
        :error "ensureList: require \$iName";
    }
    # ensure iName
    :local listIDList [/interface list find name=$iName];
    :if ([$IsEmpty $listIDList]) do={
        /interface list add name=$iName;
    }
}


# $setListAttrs
# kwargs: iName=<str>
# kwargs: iAttrs=<array>
:local setListAttrs do={
    #DEFINE global
    :global IsStr;
    :global IsNil;
    :global IsArray;
    :global IsEmpty;
    :global InValues;
    # local
    :local attrsUseEmptyStr {"include"; "exclude"};
    # check params
    :if (![$IsStr $iName]) do={
        :error "setListAttrs: require \$iName<str>";
    }
    :if (![$IsArray $iAttrs]) do={
        :error "setListAttrs: require \$iAttrs<array>";
    }
    # check list's existance
    :local idList [/interface list find name=$iName];
    :if ([$IsEmpty $idList]) do={
        :error "setListAttrs: interface list name $iName not found";
    }
    :local itemID ($idList->0);
    # iter iAttrs
    :foreach k,v in $iAttrs do={
        :if (![$IsStr $k]) do={
            :error "setListAttrs: require \$key<str> in \$iAttrs";
        }
        :if (![$IsNil $v]) do={
            :local cmd "/interface list set numbers=$itemID $k=$v;";
            :put $cmd;
        } else {
            # unset specific attribute by different ways
            :local cmd "";
            ## by empty string 
            :if ([$InValues $k $attrsUseEmptyStr]) do={
                :set cmd "/interface list set numbers=$itemID $k=\"\";";
                :put $cmd;
            }
            ## exec it
            :local cmdFunc [:parse $cmd];
            $cmdFunc;
        }
    }
}


# $ensureListInclude
# kwargs: iName=<str>
# kwargs: includeList=<array->str>
:local ensureListInclude do={
    #DEFINE global
    :global IsStr;
    :global IsArray;
    :global IsEmpty;
    :global Append;
    :global UniqueArray;
    # check params
    :if (![$IsStr $iName]) do={
        :error "ensureListInclude: require \$iName";
    }
    :if (![$IsArray $includeList]) do={
        :error "ensureListInclude: require \$includeList";
    }
    # check list's existance
    :local idList [/interface list find name=$iName];
    :if ([$IsEmpty $idList]) do={
        :error "ensureListInclude: interface list name $iName not found";
    }
    :local itemID ($idList->0);
    :foreach v in $includeList do={
        :local vIDList [/interface list find name=$v];
        :if ([$IsEmpty $vIDList]) do={
            :error "ensureListInclude: interface list name $v in \$includeList not found";
        } 
    }
    # get current include
    :local srcIncludeList [/interface list get number=$itemID "include"];
    :local mergedList [$UniqueArray [$Append $srcIncludeList $includeList]];
    # set it
    /interface list set numbers=$itemID include=$mergedList;
}


# $ensureListExclude
# kwargs: iName=<str>
# kwargs: excludeList=<array->str>
:local ensureListExclude do={
    #DEFINE global
    :global IsStr;
    :global IsArray;
    :global IsEmpty;
    :global Append;
    :global UniqueArray;
    # check params
    :if (![$IsStr $iName]) do={
        :error "ensureListExclude: require \$iName";
    }
    :if (![$IsArray $excludeList]) do={
        :error "ensureListExclude: require \$excludeList";
    }
    # check list's existance
    :local idList [/interface list find name=$iName];
    :if ([$IsEmpty $idList]) do={
        :error "ensureListExclude: interface list name $iName not found";
    }
    :local itemID ($idList->0);
    :foreach v in $excludeList do={
        :local vIDList [/interface list find name=$v];
        :if ([$IsEmpty $vIDList]) do={
            :error "ensureListExclude: interface list name $v in \$excludeList not found";
        } 
    }
    # get current include
    :local srcExcludeList [/interface list get number=$itemID "include"];
    :local mergedList [$UniqueArray [$Append $srcExcludeList $excludeList]];
    # set it
    /interface list set numbers=$itemID include=$mergedList;
}


# $addListMember
# kwargs: iName=<str>
# kwargs: intfList=<array->str>
:local addListMember do={
    #DEFINE global
    :global IsStr;
    :global IsArray;
    :global IsEmpty;
    # check params
    :if (![$IsStr $iName]) do={
        :error "addListMember: require \$iName";
    }
    :if (![$IsArray $intfList]) do={
        :error "addListMember: require \$intfList";
    }
    # check list's existance
    :local idList [/interface list find name=$iName];
    :if ([$IsEmpty $idList]) do={
        :error "addListMember: interface list name $iName not found";
    }
    :local itemID ($idList->0);
    :foreach v in $intfList do={
        # NOTE: different ros version may infect this
        :local vIDList [/interface find name=$v !dynamic];
        :if ([$IsEmpty $vIDList]) do={
            :error "addListMember: static interface name $v not found";
        } 
    }
    # add membership
    :foreach v in $intfList do={
        /interface list member add interface=$v list=$iName;
    }
}


# $ensureListMember
# kwargs: iName=<str>
# kwargs: intfList=<array->str>
:local ensureListMember do={
    #DEFINE global
    :global IsStr;
    :global IsArray;
    :global IsEmpty;
    #DEFINE helper
    :global itemsFoundEnsureOneEnabled;
    # check params
    :if (![$IsStr $iName]) do={
        :error "ensureListMember: require \$iName";
    }
    :if (![$IsArray $intfList]) do={
        :error "ensureListMember: require \$intfList";
    }
    # check list's existance
    :local idList [/interface list find name=$iName];
    :if ([$IsEmpty $idList]) do={
        :error "ensureListMember: interface list name $iName not found";
    }
    :local itemID ($idList->0);
    :foreach v in $intfList do={
        # NOTE: different ros version may infect this
        :local vIDList [/interface find name=$v !dynamic];
        :if ([$IsEmpty $vIDList]) do={
            :error "ensureListMember: static interface name $v not found";
        } 
    }
    # ensure membership
    :foreach v in $intfList do={
        :local vIDList [/interface list member find interface=$v list=$iName];
        :if ([$IsEmpty $vIDList]) do={
            /interface list member add interface=$v list=$iName;
        } else {
            $itemsFoundEnsureOneEnabled "/interface list member" $vIDList;
        }
    }
}


# $setListMemberAttrs
# kwargs: iName=<str>
# kwargs: intfList=<array->str>
:local setListMemberAttrs do={
}


# $findAllInterface
# find all enabled interface by list name
# kwargs:           List=<str>
:local findAllInterface do={
    #DEFINE global
    :global IsStr;
    :global IsEmpty;
    :global NewArray;
    :global UniqueArray;
    :global findAllItemsByTemplate;
    # check params
    :if (![$IsStr $List]) do={
        :error "findAllInterface: require \$List";
    }
    :local intfIDList [/interface list find name=$List !disabled];
    :if ([$IsEmpty $intfIDList]) do={
        :error "findAllInterface: specific \$List not exist"
    }
    # find list itself
    :local template [$NewArray];
    :set ($template->"disabled") no;
    :set ($template->"list") $List;
    :local nameList [$findAllItemsByTemplate "/interface list member" $template Output="interface"];
    # find in include
    :local includeList [/interface list get ($intfIDList->0) include];
    :foreach listName in $includeList do={
        :set ($template->"list") $listName;
        :local nList [$findAllItemsByTemplate "/interface list member" $template Output="interface"];
        :set nameList ($nameList, $nList);
    }
    :return [$UniqueArray $nameList];
}



:local package {
    "metaInfo"=$metaInfo;
    "addList"=$addList;
    "ensureList"=$ensureList;
    "setListAttrs"=$setListAttrs;
    "ensureListInclude"=$ensureListInclude;
    "ensureListExclude"=$ensureListExclude;
    "addListMember"=$addListMember;
    "ensureListMember"=$ensureListMember;
    "setListMemberAttrs"=$setListMemberAttrs;
    "findAllInterface"=$findAllInterface;
}
:return $package;
