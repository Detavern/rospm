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
    "version"="0.4.1";
    "description"="rspm configuration tools";
};


# $generateBaseURL
# Generate base url by context.
# kwargs: Context=<array>       context comes from installer or others
# return: <str>                 base url
:local generateBaseURL do={
    #DEFINE GLOBAL
    :global IsNil;
    :global IsStr;
    :global TypeofArray;
    :global ReadOption;
    # check
    :local context [$ReadOption $Context $TypeofArray];
    :local repoType ($context->"RSPMRepoType");
    :local repoName ($context->"RSPMRepoName");
    :if (![$IsStr $repoType]) do={
        :error "rspm.config.generateBaseURL: need RSPMRepoType in \$Context";
    };
    :if (![$IsStr $repoName]) do={
        :error "rspm.config.generateBaseURL: need RSPMRepoName in \$Context";
    };
    # github
    :if ($repoType = "github") do={
        :local branch ($context->"RSPMBranch");
        :return "https://raw.githubusercontent.com/$repoName/$branch/";
    }
    # NOTE: add other types here
    # fallback
    :error "rspm.config.generateBaseURL: RepoType not recognized: $repoType";
}


# $generateVersionBaseURL
# Generate base url of version control by context.
# kwargs: Context=<array>       context comes from installer or others
# return: <str>                 base url of version control
:local generateVersionBaseURL do={
    #DEFINE GLOBAL
    :global IsNil;
    :global IsStr;
    :global TypeofArray;
    :global ReadOption;
    # check
    :local context [$ReadOption $Context $TypeofArray];
    :local repoType ($context->"RSPMRepoType");
    :local repoName ($context->"RSPMRepoName");
    :local version ($context->"RSPMVersion");
    :if (![$IsStr $repoType]) do={
        :error "rspm.config.generateVersionBaseURL: need RSPMRepoType in \$Context";
    };
    :if (![$IsStr $repoName]) do={
        :error "rspm.config.generateVersionBaseURL: need RSPMRepoName in \$Context";
    };
    :if (![$IsStr $version]) do={
        :error "rspm.config.generateVersionBaseURL: need RSPMVersion in \$Context";
    };
    # github
    :if ($repoType = "github") do={
        :return "https://raw.githubusercontent.com/$repoName/v$version/";
    }
    # NOTE: add other types here
    # fallback
    :error "rspm.config.generateVersionBaseURL: RepoType not recognized: $repoType";
}


# $generateConfig
:local generateConfig do={
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


# $generatePackageConfig
# Generate package config by context and return modified context.
# kwargs: Context=<array>       context comes from installer or others
# return: <array>               modified context
:local generatePackageConfig do={
    #DEFINE GLOBAL
    :global IsNil;
    :global IsNothing;
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
            "RSPMRepoType"="github";
            "RSPMRepoName"="Detavern/rspm";
            "RSPMBranch"="master";
            "RSPMOwner"="rspm";
        };
    }
    # update environment from context
    :foreach k,v in $context do={
        :set (($config->"environment")->$k) $v;
    }
    # add RSPMBaseURL
    :if ([$IsNothing (($config->"environment")->"RSPMBaseURL")]) do={
        :set (($config->"environment")->"RSPMBaseURL") \
            [[$GetFunc "rspm.config.generateBaseURL"] Context=($config->"environment")];
    }
    # query remote version
    :local baseURL (($config->"environment")->"RSPMBaseURL");
    :local resVersionURL ($baseURL . "res/version.rsc");
    :local resVersion [[$GetFunc "tool.remote.loadRemoteVar"] URL=$resVersionURL];
    # add RSPMVersion as current version
    :set (($config->"environment")->"RSPMVersion") $resVersion;
    # add RSPMVersionBaseURL
    :if ([$IsNothing (($config->"environment")->"RSPMVersionBaseURL")]) do={
        :set (($config->"environment")->"RSPMVersionBaseURL") \
            [[$GetFunc "rspm.config.generateVersionBaseURL"] Context=($config->"environment")];
    }
    # load remote package info
    :local packageInfoURL ($baseURL . "res/package-info.rsc");
    :put "Get: $packageInfoURL";
    :local packageInfo [[$GetFunc "tool.remote.loadRemoteVar"] URL=$packageInfoURL];
    # update config
    :foreach k,v in $packageInfo do={
        :set ($config->$k) $v;
    }
    # make new config.rspm.package
    [$CreateConfig $configName $config \
        Force=true Owner=(($config->"environment")->"RSPMOwner") \
        Description="Auto-generated rspm package configuration."];
    :put "Configuration: $configName initialized."
    :return ($config->"environment");
}


# $generatePackageExtConfig
# kwargs: Context=<array>       context comes from installer or others
:local generatePackageExtConfig do={
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
    :local env ($configPkg->"environment");
    # load remote package info
    :local packageInfoURL (($env->"RSPMBaseURL") . "res/package-info-ext.rsc");
    :put "Get: $packageInfoURL";
    :local packageInfo [[$GetFunc "tool.remote.loadRemoteVar"] URL=$packageInfoURL];
    # update config
    :foreach k,v in $packageInfo do={
        :set ($config->$k) $v;
    }
    # make new config.rspm.package
    [$CreateConfig $configName $config \
        Force=true Owner=($env->"RSPMOwner") \
        Description="Auto-generated rspm package extension configuration."];
    :put "Configuration: $configName initialized."
}


:local package {
    "metaInfo"=$metaInfo;
    "generateBaseURL"=$generateBaseURL;
    "generateVersionBaseURL"=$generateVersionBaseURL;
    "generateConfig"=$generateConfig;
    "generatePackageConfig"=$generatePackageConfig;
    "generatePackageExtConfig"=$generatePackageExtConfig;
}
:return $package;
