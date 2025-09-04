#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   rospm.reset
# ===================================================================
# ALL package level functions follows lower camel case.
# This package provides tools for resetting ROSPM configuration and cleaning global variables.
#
# Copyright (c) 2020-2025 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="rospm.reset";
	"version"="0.7.0.a";
	"description"="This package provides tools for resetting ROSPM configuration and cleaning global variables.";
};


# TODO: complete this!
:local resetConfig do={

}


# $removeGlobal
# Remove global variables & functions by the package metainfo.
# This procedure will ignore any package name that starts with "global-"
# to keep the integrity of ROSPM.
# kwargs: MetaInfo=<metaInfo>               package name
:local removeGlobal do={
    #DEFINE global
    :global Nil;
    :global IsNothing;
    :global StartsWith;
    :global IsDict;
    # check
    :if (![$IsDict $MetaInfo]) do={
        :error "rospm.reset.removeGlobal: \$MetaInfo shoud be a dict-like array";
    }
    # local
    :local pkgName ($MetaInfo->"name");
    :if ([$StartsWith $pkgName "global-"]) do={
        :return $Nil;
    }
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
