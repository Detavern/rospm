#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   rospm.reset
# ===================================================================
# ALL package level functions follows lower camel case.
# rospm configuration reset tools
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
    "name"="rospm.reset";
    "version"="0.5.0";
    "description"="rospm configuration reset tools";
};


:local resetConfig do={

}


# $removeGlobal
# kwargs: MetaInfo=<metaInfo>               package name
:local removeGlobal do={
    #DEFINE global
    :global IsNothing;
    :global IsDict;
    # check
    :if (![$IsDict $MetaInfo]) do={
        :error "rospm.reset.removeGlobal: \$MetaInfo shoud be a dict-like array";
    }
    # local
    :local funcList ($MetaInfo->"global-functions");
    :local varList ($MetaInfo->"global-variables");
    :if (![$IsNothing $funcList]) do={
        :foreach v in $funcList do={
            /system/script/environment/remove [/system/script/environment/find name="$v"];
        }
    }
    :if (![$IsNothing $varList]) do={
        :foreach v in $varList do={
            /system/script/environment/remove [/system/script/environment/find name="$v"];
        }  
    }
}


:local package {
    "metaInfo"=$metaInfo;
    "resetConfig"=$resetConfig;
    "removeGlobal"=$removeGlobal;
}
:return $package;
