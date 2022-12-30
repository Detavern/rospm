#!rsc by RouterOS
# ===================================================================
# |       RSPM Packages      |   rspm.config
# ===================================================================
# ALL package level functions follows lower camel case.
# rspm configuration tools
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rspm/blob/master/LICENSE.md
#
:local metaInfo {
    "name"="rspm.config";
    "version"="0.4.0";
    "description"="rspm configuration tools";
};


# $initConfig
:local initConfig do={
    #DEFINE GLOBAL
    :global NewArray;
    :global GetFunc;
    :global CreateConfig;
    # const
    :local configName "config.rspm";
    :local description "Auto-generated rspm base configuration.";
    :local environment {
        "GlobalCacheFuncEnabled"=true;
        "GlobalCacheFuncSize"=10;
    };
    :local configList {
        {
            "name"="config.rspm";
            "description"=$description;
        }
    }
    :local configMapping {
        "config.rspm"=0;
    }
    :local config {
        "environment"=$environment;
        "configList"=$configList;
        "configMapping"=$configMapping;
    }
    # make new config.rspm.package
    [$CreateConfig $configName $config Force=true \
        Owner="rspm" Description=$description];
    :put "Configuration: $configName initialized."
}


# $initPackageConfig
# kwargs: Context=<array>       context comes from installer or others
:local initPackageConfig do={
    #DEFINE GLOBAL
    :global IsNil;
    :global TypeofArray;
    :global ReadOption;
    :global NewArray;
    :global GetFunc;
    :global CreateConfig;
    :global FindPackage;
    # check
    :local context [$ReadOption $Context $TypeofArray];
    :if ([$IsNil $context]) do={:set context [$NewArray ]};
    # const
    :local configName "config.rspm.package";
    :local config {
        "environment"={
            "RSPMBaseURL"="https://raw.githubusercontent.com/Detavern/rspm/master/";
            "RSPMOwner"="rspm";
        };
    }
    # update environment
    :foreach k,v in $context do={
        :set (($config->"environment")->$k) $v;
    }
    :local environment ($config->"environment");
    # add resource version
    :local resVersionURL (($environment->"RSPMBaseURL") . "res/version.rsc");
    :local resVersion [[$GetFunc "tool.remote.loadRemoteVar"] URL=$resVersionURL];
    :set (($config->"environment")->"RSPMVersion") $resVersion;
    # load remote package info
    :local packageInfoURL (($environment->"RSPMBaseURL") . "res/package-info.rsc");
    :put "Get: $packageInfoURL";
    :local packageInfo [[$GetFunc "tool.remote.loadRemoteVar"] URL=$packageInfoURL];
    # update config
    :foreach k,v in $packageInfo do={
        :set ($config->$k) $v;
    }
    # make new config.rspm.package
    [$CreateConfig $configName $config Force=true \
        Owner=($environment->"RSPMOwner") Description="Auto-generated rspm package configuration."];
    :put "Configuration: $configName initialized."
}


# $initPackageExtConfig
# kwargs: Context=<array>       context comes from installer or others
:local initPackageExtConfig do={
    #DEFINE GLOBAL
    :global IsNil;
    :global TypeofArray;
    :global ReadOption;
    :global NewArray;
    :global GetFunc;
    :global GetConfig;
    :global CreateConfig;
    :global FindPackage;
    # check
    :local context [$ReadOption $Context $TypeofArray];
    :if ([$IsNil $context]) do={:set context [$NewArray ]};
    # const
    :local configName "config.rspm.package.ext";
    :local config {
        "environment"=[$NewArray ];
    }
    # update environment
    :foreach k,v in $context do={
        :set (($config->"environment")->$k) $v;
    }
    :local environment ($config->"environment");
    # get package config
    :local configPkg [$GetConfig "config.rspm.package"];
    :local environmentPkg ($configPkg->"environment");
    # load remote package info
    :local packageInfoURL (($environmentPkg->"RSPMBaseURL") . "res/package-info-ext.rsc");
    :put "Get: $packageInfoURL";
    :local packageInfo [[$GetFunc "tool.remote.loadRemoteVar"] URL=$packageInfoURL];
    # update config
    :foreach k,v in $packageInfo do={
        :set ($config->$k) $v;
    }
    # make new config.rspm.package
    [$CreateConfig $configName $config Force=true \
        Owner=($environmentPkg->"RSPMOwner") Description="Auto-generated rspm package extension configuration."];
    :put "Configuration: $configName initialized."
}


:local package {
    "metaInfo"=$metaInfo;
    "initConfig"=$initConfig;
    "initPackageConfig"=$initPackageConfig;
    "initPackageExtConfig"=$initPackageExtConfig;
}
:return $package;