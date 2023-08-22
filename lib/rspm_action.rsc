#!rsc by RouterOS
# ===================================================================
# |       RSPM Packages      |   rspm.action
# ===================================================================
# ALL package level functions follows lower camel case.
# The real action(like: install, upgrade, etc) behind the scenes. Should not be used directly.
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rspm/blob/master/LICENSE.md
#
:local metaInfo {
    "name"="rspm.action";
    "version"="0.4.1";
    "description"="The real action(like: install, upgrade, etc) behind the scenes. Should not be used directly.";
};


# $register
# Register a local package into package manager.
# If it is a global package, load it.
# kwargs: Report=<array->str>(<report>)     package report
:local register do={
    #DEFINE global
    :global Nil;
    :global IsNil;
    :global TypeofArray;
    :global GetConfig;
    :global InValues;
    :global ReadOption;
    :global LoadPackage;
    :global UpdateConfig;
    # init
    :local configExtPkgName "config.rspm.package.ext";
    :local configExt [$GetConfig $configExtPkgName];
    # read opt
    :local report [$ReadOption $Report $TypeofArray];
    # check params
    :if ([$IsNil $report]) do={
        :error "rspm.action.register: require \$Report";
    }
    # report
    :local pkgName ($report->"package");
    :local state ($report->"state");
    :if (![$InValues "register" ($report->"actions")]) do={
        :error "rspm.action.register: action not found.";
    }
    # register
    :local meta ($report->"metaScript");
    :local ml ($configExt->"packageList");
    :local mp ($configExt->"packageMapping");
    :set ($mp->$pkgName) [:len $ml];
    :set ($ml->[:len $ml]) $meta;
    :put "Updating extension package list...";
    [$UpdateConfig $configExtPkgName $configExt];
    # if global, load it
    :if (($meta->"global")) do={
        :put "Loading global package...";
        [$LoadPackage $pkgName];
    }
    :put "The package has been registed.";
    :return $Nil;
}


# $registerExt
# Register an extension package into package manager.
# kwargs: URL=<str>                 package url, use for install ext package
:local registerExt do={
    #DEFINE global
    :global Nil;
    :global IsNil;
    :global IsNothing;
    :global TypeofStr;
    :global Replace;
    :global GetFunc;
    :global InValues;
    :global ReadOption;
    :global ParseMetaSafe;
    :global ValidatePackageContent;
    :global GetConfig;
    :global UpdateConfig;
    :global LoadPackage;
    # env
    :global EnvRSPMOwner;
    # init
    :local pkgStr "";
    :local configPkgName "config.rspm.package";
    :local configExtPkgName "config.rspm.package.ext";
    :local config [$GetConfig $configPkgName];
    :local configExt [$GetConfig $configExtPkgName];
    # read opt
    :local pkgUrl [$ReadOption $URL $TypeofStr];
    # check params
    :if ([$IsNil $pkgUrl]) do={
        :error "rspm.action.registerExt: require \$URL";
    }
    # install by url
    :put "Get: $pkgUrl";
    :set pkgStr [[$GetFunc "tool.remote.loadRemoteSource"] URL=$pkgUrl Normalize=true];
    # load meta info from package string
    :local metaR [$ParseMetaSafe $pkgStr];
    :local pkgName ($metaR->"name");
    :local metaUrl ($metaR->"url");
    # validate package
    :local va {"type"="code";"url"=true};
    :put "Validating package $pkgName...";
    :local pkg [$NewArray ];
    :set ($pkg->"metaInfo") $metaR;
    :if (![$ValidatePackageContent $pkg $va]) do={
        :error "rspm.action.registerExt: package validate failed, check log for detail";
    };
    # set proxy url
    :if ($metaUrl != $pkgUrl) do={
        :set ($metaR->"proxyUrl") $pkgUrl;
    }
    # ensure package name not in config
    :if ([$IsNum (($config->"packageMapping")->$pkgName)]) do={
        :put "Same package name $pkgName found in package list.";
        :put "Using \"rspm.install\" with package name $pkgName instead.";
        :error "rspm.action.registerExt: not an extension package.";
    }
    # update ext config
    :put "Updating config.rspm.package.ext...";
    :local pkgExtNum (($configExt->"packageMapping")->$pkgName);
    :local pm ($configExt->"packageMapping");
    :local pl ($configExt->"packageList");
    :if ([$IsNothing $pkgExtNum]) do={
        :set ($pm->$pkgName) [:len $pl];
        :set ($pl->[:len $pl]) $metaR;
    } else {
        :set ($pl->$pkgExtNum) $metaR;
    }
    [$UpdateConfig $configExtPkgName $configExt];
    :return $Nil;
}


# $install
# kwargs: Report=<array->str>(<report>)     package report
:local install do={
    #DEFINE global
    :global Nil;
    :global IsNil;
    :global IsNothing;
    :global TypeofArray;
    :global Replace;
    :global GetFunc;
    :global InValues;
    :global ReadOption;
    :global LoadPackage;
    # env
    :global EnvRSPMBaseURL;
    :global EnvRSPMOwner;
    # init
    :local pkgUrl "";
    :local pkgStr "";
    :local configPkgName "config.rspm.package";
    # read opt
    :local report [$ReadOption $Report $TypeofArray];
    # check params
    :if ([$IsNil $report]) do={
        :error "rspm.action.install: require \$Report";
    }
    # report
    :local pkgName ($report->"package");
    :local state ($report->"state");
    :if (![$InValues "install" ($report->"actions")]) do={
        :error "rspm.action.install: action not found.";
    }
    # install
    :local versionR (($report->"metaConfig")->"version");
    # determine pkg url
    :if (($report->"configName") = $configPkgName) do={
        :put "Installing core package $pkgName, latest version is $versionR";
        :local pn [$Replace $pkgName "." "_"];
        :set pkgUrl ($EnvRSPMBaseURL . "lib/$pn.rsc")
    } else {
        :put "Installing extension package $pkgName, latest version is $versionR";
        # if proxy url exists, use it instead of raw url
        :set pkgUrl (($report->"metaConfig")->"proxyUrl");
        :if ([$IsNothing $pkgUrl]) do={
            :set pkgUrl (($report->"metaConfig")->"url");
        }
    };
    :put "Get: $pkgUrl";
    :set pkgStr [[$GetFunc "tool.remote.loadRemoteSource"] URL=$pkgUrl Normalize=true];
    :put "Writing source into repository...";
    :local fileName [$Replace $pkgName "." "_"];
    /system/script/add name=$fileName source=$pkgStr owner=$EnvRSPMOwner;
    # if global, load it
    :if ((($report->"metaConfig")->"global")) do={
        :put "Loading global package...";
        [$LoadPackage $pkgName];
    }
    :put "The package has been installed.";
    :return $Nil;
}


# $reinstall
# kwargs: Report=<array->str>(<report>)     package report
:local reinstall do={
    #DEFINE global
    :global Nil;
    :global IsNil;
    :global IsNothing;
    :global TypeofArray;
    :global Replace;
    :global GetFunc;
    :global InValues;
    :global ReadOption;
    :global FindPackage;
    :global LoadPackage;
    :global GlobalCacheFuncRemovePrefix;
    # env
    :global EnvRSPMBaseURL;
    :global EnvRSPMOwner;
    # init
    :local pkgUrl "";
    :local pkgStr "";
    :local configPkgName "config.rspm.package";
    # read opt
    :local report [$ReadOption $Report $TypeofArray];
    # check params
    :if ([$IsNil $report]) do={
        :error "rspm.action.reinstall: require \$Report";
    }
    # report
    :local pkgName ($report->"package");
    :local state ($report->"state");
    :if (![$InValues "reinstall" ($report->"actions")]) do={
        :error "rspm.action.reinstall: action not found.";
    }
    # reinstall
    :local versionR (($report->"metaConfig")->"version");
    # determine pkg url
    :if (($report->"configName") = $configPkgName) do={
        :put "Reinstalling core package $pkgName, latest version is $versionR";
        :local pn [$Replace $pkgName "." "_"];
        :set pkgUrl ($EnvRSPMBaseURL . "lib/$pn.rsc")
    } else {
        :put "Reinstalling extension package $pkgName, latest version is $versionR";
        # if proxy url exists, use it instead of raw url
        :set pkgUrl (($report->"metaConfig")->"proxyUrl");
        :if ([$IsNothing $pkgUrl]) do={
            :set pkgUrl (($report->"metaConfig")->"url");
        }
    };
    :put "Get: $pkgUrl";
    :set pkgStr [[$GetFunc "tool.remote.loadRemoteSource"] URL=$pkgUrl Normalize=true];
    :put "Writing source into repository...";
    /system/script/set [$FindPackage $pkgName] source=$pkgStr owner=$EnvRSPMOwner;
    :put "Clean function cache...";
    [$GlobalCacheFuncRemovePrefix $pkgName];
    # if global, load it
    :if ((($report->"metaConfig")->"global")) do={
        :put "Loading global package...";
        [[$GetFunc "rspm.reset.removeGlobal"] MetaInfo=($report->"metaScript")];
        [$LoadPackage $pkgName];
    }
    :put "The package has been reinstalled.";
    :return $Nil;
}


# $upgrade
# Upgrade an outdated package to the latest.
# kwargs: Report=<array->str>(<report>)     package report
:local upgrade do={
    #DEFINE global
    :global Nil;
    :global IsNil;
    :global IsNothing;
    :global TypeofArray;
    :global Replace;
    :global GetFunc;
    :global InValues;
    :global ReadOption;
    :global FindPackage;
    :global LoadPackage;
    :global GlobalCacheFuncRemovePrefix;
    # env
    :global EnvRSPMBaseURL;
    :global EnvRSPMOwner;
    # init
    :local pkgUrl "";
    :local pkgStr "";
    :local configPkgName "config.rspm.package";
    # read opt
    :local report [$ReadOption $Report $TypeofArray];
    # check params
    :if ([$IsNil $report]) do={
        :error "rspm.action.upgrade: require \$Report";
    }
    # report
    :local pkgName ($report->"package");
    :local state ($report->"state");
    :if (![$InValues "upgrade" ($report->"actions")]) do={
        :error "rspm.action.upgrade: action not found.";
    }
    # upgrade
    :local versionR (($report->"metaConfig")->"version");
    :local versionL (($report->"metaScript")->"version");
    # determine pkg url
    :if (($report->"configName") = $configPkgName) do={
        :put "Upgrading core package $pkgName, latest version is $versionR(current: $versionL)";
        :local pn [$Replace $pkgName "." "_"];
        :set pkgUrl ($EnvRSPMBaseURL . "lib/$pn.rsc")
    } else {
        :put "Upgrading extension package $pkgName, latest version is $versionR";
        # if proxy url exists, use it instead of raw url
        :set pkgUrl (($report->"metaConfig")->"proxyUrl");
        :if ([$IsNothing $pkgUrl]) do={
            :set pkgUrl (($report->"metaConfig")->"url");
        }
    };
    :put "Get: $pkgUrl";
    :set pkgStr [[$GetFunc "tool.remote.loadRemoteSource"] URL=$pkgUrl Normalize=true];
    :put "Writing source into repository...";
    /system/script/set [$FindPackage $pkgName] source=$pkgStr owner=$EnvRSPMOwner;
    :put "Clean function cache...";
    [$GlobalCacheFuncRemovePrefix $pkgName];
    # if global, load it
    :if ((($report->"metaConfig")->"global")) do={
        :put "Loading global package...";
        [[$GetFunc "rspm.reset.removeGlobal"] MetaInfo=($report->"metaScript")];
        [$LoadPackage $pkgName];
    }
    :put "The package has been upgraded.";
    :return $Nil;
}


# $downgrade
# TODO: For development only. This is not a literally downgrade function.
# kwargs: Report=<array->str>(<report>)     package report
:local downgrade do={
    #DEFINE global
    :global Nil;
    :global IsNil;
    :global IsNothing;
    :global TypeofArray;
    :global Replace;
    :global GetFunc;
    :global InValues;
    :global ReadOption;
    :global FindPackage;
    :global LoadPackage;
    :global GlobalCacheFuncRemovePrefix;
    # env
    :global EnvRSPMBaseURL;
    :global EnvRSPMOwner;
    # init
    :local pkgUrl "";
    :local pkgStr "";
    :local configPkgName "config.rspm.package";
    # read opt
    :local report [$ReadOption $Report $TypeofArray];
    # check params
    :if ([$IsNil $report]) do={
        :error "rspm.action.downgrade: require \$Report";
    }
    # report
    :local pkgName ($report->"package");
    :local state ($report->"state");
    :if (![$InValues "downgrade" ($report->"actions")]) do={
        :error "rspm.action.downgrade: action not found.";
    }
    # downgrade
    :local versionR (($report->"metaConfig")->"version");
    :local versionL (($report->"metaScript")->"version");
    # determine pkg url
    :if (($report->"configName") = $configPkgName) do={
        :put "Downgrading core package $pkgName, latest version is $versionR(current: $versionL)";
        :local pn [$Replace $pkgName "." "_"];
        :set pkgUrl ($EnvRSPMBaseURL . "lib/$pn.rsc")
    } else {
        :put "Downgrading extension package $pkgName, latest version is $versionR";
        # if proxy url exists, use it instead of raw url
        :set pkgUrl (($report->"metaConfig")->"proxyUrl");
        :if ([$IsNothing $pkgUrl]) do={
            :set pkgUrl (($report->"metaConfig")->"url");
        }
    };
    :put "Get: $pkgUrl";
    :set pkgStr [[$GetFunc "tool.remote.loadRemoteSource"] URL=$pkgUrl Normalize=true];
    :put "Writing source into repository...";
    /system/script/set [$FindPackage $pkgName] source=$pkgStr owner=$EnvRSPMOwner;
    :put "Clean function cache...";
    [$GlobalCacheFuncRemovePrefix $pkgName];
    # if global, load it
    :if ((($report->"metaConfig")->"global")) do={
        :put "Loading global package...";
        [[$GetFunc "rspm.reset.removeGlobal"] MetaInfo=($report->"metaScript")];
        [$LoadPackage $pkgName];
    }
    :put "The package has been downgraded.";
    :return $Nil;
}


# $remove
# Remove an installed package from local repository.
# kwargs: Report=<array->str>(<report>)     package report
:local remove do={
    #DEFINE global
    :global Nil;
    :global IsNil;
    :global IsNothing;
    :global TypeofArray;
    :global GetFunc;
    :global InValues;
    :global ReadOption;
    :global GetConfig;
    :global FindPackage;
    :global GlobalCacheFuncRemovePrefix;
    # init
    :local configPkgName "config.rspm.package";
    :local config [$GetConfig $configPkgName];
    # read opt
    :local report [$ReadOption $Report $TypeofArray];
    # check params
    :if ([$IsNil $report]) do={
        :error "rspm.action.remove: require \$Report";
    }
    # report
    :local pkgName ($report->"package");
    :local state ($report->"state");
    :if (![$InValues "remove" ($report->"actions")]) do={
        :error "rspm.action.remove: action not found.";
    }
    # check removable or not
    :local epkgList ($config->"essentialPackageList");
    :if ([$InValues $pkgName $epkgList]) do={
        :put "Package $pkgName is an essential package for RSPM.";
        :put "Removing this package will corrupt RSPM.";
        :error "rspm.action.remove: target package is essential.";
    }
    # remove
    :put "Removing the package $pkgName...";
    /system/script/remove [$FindPackage $Package];
    :put "Clean function cache...";
    [$GlobalCacheFuncRemovePrefix $pkgName];
    # if global, remove it
    :if ((($report->"metaScript")->"global")) do={
        :put "Removing global functions and variables from environment...";
        [[$GetFunc "rspm.reset.removeGlobal"] MetaInfo=($report->"metaScript")];
    }
    :put "The package has been removed.";
    :return $Nil;
}


:local package {
    "metaInfo"=$metaInfo;
    "register"=$register;
    "registerExt"=$registerExt;
    "install"=$install;
    "reinstall"=$reinstall;
    "upgrade"=$upgrade;
    "downgrade"=$downgrade;
    "remove"=$remove;
}
:return $package