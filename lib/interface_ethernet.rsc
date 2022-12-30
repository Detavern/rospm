#!rsc by RouterOS
# ===================================================================
# |       RSPM Packages      |   interface.ethernet
# ===================================================================
# ALL package level functions follows lower camel case.
# 
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rspm/blob/master/LICENSE.md
#
:local metaInfo {
    "name"="interface.ethernet";
    "version"="0.4.0";
    "description"="";
};


# $rename
# kwargs: NewName=<str>                 ethernet's new name
# opt kwargs: DefaultName=<str>         ethernet's original default-name   
# opt kwargs: Name=<str>                ethernet's original name
:local rename do={
    #DEFINE global
    :global TypeofStr;
    :global IsEmpty;
    :global IsStr;
    # check name
    :if (![$IsStr $NewName]) do={
        :error "interface.ethernet.rename: require \$NewName";
    }
    # find ID by DefaultName & replace its name
    :if ([$IsStr $DefaultName]) do={
        :local nicIDList [/interface/ethernet/find default-name=$DefaultName];
        :if ([$IsEmpty $nicIDList]) do={
            :error "interface.ethernet.rename: $DefaultName not found";
        } else {
            :local nicID ($nicIDList->0);
            /interface/ethernet/set name=$NewName numbers=$nicID;
        }
        :return true;
    }
    # find ID by Name & replace its name
    :if ([$IsStr $Name]) do={
        :local nicIDList [/interface/ethernet/find name=$Name];
        :if ([$IsEmpty $nicIDList]) do={
            :error "interface.ethernet.rename: $Name not found";
        } else {
            :local nicID ($nicIDList->0);
            /interface/ethernet/set name=$NewName numbers=$nicID;
        }
        :return true;
    }
    :error "interface.ethernet.rename: require one of \$DefaultName, \$Name";
}


# $renameAll
# kwargs: Template=<array->str>         original default-name pattern to new name pattern array
# Example Template
# {
#     "ether"="ETH-";
#     "sfp"="SFP-";
#     "sfp-sfpplus"="SFPP-";
# }
# ether1        ->      ETH-1
# sfp1          ->      SFP-1
# sfp-sfpplus1  ->      SFPP-1
:local renameAll do={
    #DEFINE global
    :global TypeofStr;
    :global IsArray;
    :global Replace;
    :global StartsWith;
    # check template
    :if (![$IsArray $Template]) do={
        :error "interface.ethernet.renameAll: require \$Template";
    }
    # for
    :foreach i in=[/interface/ethernet/find] do={
        :local newName [/interface/ethernet/get $i "default-name"];
        :local newNameP "";
        # select longest match pattern
        :foreach k,v in=$Template do={
            :if ([$StartsWith $newName $k]) do={
                :if ([:len $k]>[:len $newNameP]) do={
                    :set newNameP $k;
                }
            }
        }
        # replace it
        :if ($newNameP != "") do={
            :local name [$Replace $newName $newNameP ($Template->$newNameP)];
            /interface/ethernet/set name=$name numbers=$i;
        }
    }
}


# $resetAll
# reset all ethernet interface by its default-name attributes
:local resetAll do={
    :foreach i in=[/interface/ethernet/find] do={
        :local defaultName [/interface/ethernet/get $i "default-name"];
        /interface/ethernet/set name=$defaultName numbers=$i;
    }
}


:local package {
    "metaInfo"=$metaInfo;
    "rename"=$rename;
    "renameAll"=$renameAll;
    "resetAll"=$resetAll;
}
:return $package;
