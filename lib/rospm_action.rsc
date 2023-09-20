#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   rospm.action
# ===================================================================
# ALL package level functions follows lower camel case.
# The real action(like: install, upgrade, etc) behind the scenes. Should not be used directly.
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
    "name"="rospm.action";
    "version"="0.4.2";
    "description"="The real action(like: install, upgrade, etc) behind the scenes. Should not be used directly.";
};


# $register
# Register a local package into extension config of package manager.
# If it is a global package, load it.
# kwargs: Report=<array->str>(<report>)     package report
:local register do={
    #DEFINE global
    :global Nil;
    :global IsNil;
    :global IsNothing;
    :global TypeofArray;
    :global GetConfig;
    :global Replace;
    :global InValues;
    :global ReadOption;
    :global LoadPackage;
    :global UpdateConfig;
    :global ValidateMetaInfo;
    # env
    :global EnvROSPMOwner;
    # init
    :local configExtPkgName "config.rospm.package.ext";
    :local configExt [$GetConfig $configExtPkgName];
    # read opt
    :local report [$ReadOption $Report $TypeofArray];
    # check params
    :if ([$IsNil $report]) do={
        :error "rospm.action.register: require \$Report";
    }
    # report
    :local pkgName ($report->"package");
    :local state ($report->"state");
    :if (![$InValues "register" ($report->"actions")]) do={
        :error "rospm.action.register: action not found.";
    }
    # validate
    :local metaList ($report->"metaScript");
    :local va {"type"="code";"extl"=true};
    :local vres [$ValidateMetaInfo $metaList $va];
    :if (!($vres->"flag")) do={
        :put "There are some errors in the meta info, check it first!";
        :foreach reason in ($vres->"reasons") do={
            :put "  $reason";
        }
        :error "rospm.action.register: could not validate target package.";
    }
    # register
    :local plen [:len ($configExt->"packageList")];
    :set (($configExt->"packageMapping")->$pkgName) $plen;
    :set (($configExt->"packageList")->$plen) $metaList;
    :put "Updating extension package list...";
    [$UpdateConfig $configExtPkgName $configExt];
    # reset owner
    :local scriptName [$Replace $pkgName "." "_"];
    /system/script/set [/system/script/find name=$scriptName] owner $EnvROSPMOwner;
    # if global, load it
    :if (($meta->"global")) do={
        :put "Loading global package...";
        [$LoadPackage $pkgName];
    }
    :put "The package has been registed.";
    :return $Nil;
}


# $install
# Install a core package.
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
    :global EnvROSPMBaseURL;
    :global EnvROSPMOwner;
    # init
    :local pkgUrl "";
    :local pkgStr "";
    :local configPkgName "config.rospm.package";
    # read opt
    :local report [$ReadOption $Report $TypeofArray];
    # check params
    :if ([$IsNil $report]) do={
        :error "rospm.action.install: require \$Report";
    }
    # report
    :local pkgName ($report->"package");
    :local state ($report->"state");
    :if (![$InValues "install" ($report->"actions")]) do={
        :error "rospm.action.install: action not found.";
    }
    # install
    :local versionR (($report->"metaConfig")->"version");
    # determine pkg url
    :if (($report->"configName") = $configPkgName) do={
        :put "Installing core package $pkgName, latest version is $versionR";
        :local pn [$Replace $pkgName "." "_"];
        :set pkgUrl ($EnvROSPMBaseURL . "lib/$pn.rsc")
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
    /system/script/add name=$fileName source=$pkgStr owner=$EnvROSPMOwner;
    # if global, load it
    :if ((($report->"metaConfig")->"global")) do={
        :put "Loading global package...";
        [$LoadPackage $pkgName];
    }
    :put "The package has been installed.";
    :return $Nil;
}


# $installExt
# Install an extension package into package manager.
# kwargs: URL=<str>                 package url, use for install ext package
:local installExt do={
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
    :global ValidateMetaInfo;
    :global GetConfig;
    :global UpdateConfig;
    :global LoadPackage;
    # env
    :global EnvROSPMOwner;
    # init
    :local pkgStr "";
    :local configPkgName "config.rospm.package";
    :local configExtPkgName "config.rospm.package.ext";
    :local config [$GetConfig $configPkgName];
    :local configExt [$GetConfig $configExtPkgName];
    # read opt
    :local pkgUrl [$ReadOption $URL $TypeofStr];
    # check params
    :if ([$IsNil $pkgUrl]) do={
        :error "rospm.action.installExt: require \$URL";
    }
    # install by url
    :put "Get: $pkgUrl";
    :set pkgStr [[$GetFunc "tool.remote.loadRemoteSource"] URL=$pkgUrl Normalize=true];
    # load meta info from package string
    :local metaR [$ParseMetaSafe $pkgStr];
    :local pkgName ($metaR->"name");
    :local metaUrl ($metaR->"url");
    # validate package
    :local va {"type"="code";"ext"=true};
    :put "Validating meta info from package: $pkgName...";
    :local vres [$ValidateMetaInfo $metaR $va];
    if (!($vres->"flag")) do={
        :put "There are some errors in the meta info, check it first!";
        :foreach reason in ($vres->"reasons") do={
            :put "  $reason";
        }
        :error "rospm.action.installExt: could not validate target package.";
    }
    # set proxy url
    :if ($metaUrl != $pkgUrl) do={
        :set ($metaR->"proxyUrl") $pkgUrl;
    }
    # ensure package name not in config
    :if ([$IsNum (($config->"packageMapping")->$pkgName)]) do={
        :put "Same package name $pkgName found in package list.";
        :put "Using \"rospm.install\" with package name $pkgName instead.";
        :error "rospm.action.installExt: not an extension package.";
    }
    # update ext config
    :put "Updating config.rospm.package.ext...";
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


# $reinstall
# Reinstall the package by current state report.
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
    :global EnvROSPMBaseURL;
    :global EnvROSPMOwner;
    # init
    :local pkgUrl "";
    :local pkgStr "";
    :local configPkgName "config.rospm.package";
    # read opt
    :local report [$ReadOption $Report $TypeofArray];
    # check params
    :if ([$IsNil $report]) do={
        :error "rospm.action.reinstall: require \$Report";
    }
    # report
    :local pkgName ($report->"package");
    :local state ($report->"state");
    :if (![$InValues "reinstall" ($report->"actions")]) do={
        :error "rospm.action.reinstall: action not found.";
    }
    # reinstall
    :local versionR (($report->"metaConfig")->"version");
    # determine pkg url
    :if (($report->"configName") = $configPkgName) do={
        :put "Reinstalling core package $pkgName, latest version is $versionR";
        :local pn [$Replace $pkgName "." "_"];
        :set pkgUrl ($EnvROSPMBaseURL . "lib/$pn.rsc")
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
    /system/script/set [$FindPackage $pkgName] source=$pkgStr owner=$EnvROSPMOwner;
    :put "Clean function cache...";
    [$GlobalCacheFuncRemovePrefix $pkgName];
    # if global, load it
    :if ((($report->"metaConfig")->"global")) do={
        :put "Loading global package...";
        [[$GetFunc "rospm.reset.removeGlobal"] MetaInfo=($report->"metaScript")];
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
    :global EnvROSPMBaseURL;
    :global EnvROSPMOwner;
    # init
    :local pkgUrl "";
    :local pkgStr "";
    :local configPkgName "config.rospm.package";
    # read opt
    :local report [$ReadOption $Report $TypeofArray];
    # check params
    :if ([$IsNil $report]) do={
        :error "rospm.action.upgrade: require \$Report";
    }
    # report
    :local pkgName ($report->"package");
    :local state ($report->"state");
    :if (![$InValues "upgrade" ($report->"actions")]) do={
        :error "rospm.action.upgrade: action not found.";
    }
    # upgrade
    :local versionR (($report->"metaConfig")->"version");
    :local versionL (($report->"metaScript")->"version");
    # determine pkg url
    :if (($report->"configName") = $configPkgName) do={
        :put "Upgrading core package $pkgName, latest version is $versionR(current: $versionL)";
        :local pn [$Replace $pkgName "." "_"];
        :set pkgUrl ($EnvROSPMBaseURL . "lib/$pn.rsc")
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
    /system/script/set [$FindPackage $pkgName] source=$pkgStr owner=$EnvROSPMOwner;
    :put "Clean function cache...";
    [$GlobalCacheFuncRemovePrefix $pkgName];
    # if global, load it
    :if ((($report->"metaConfig")->"global")) do={
        :put "Loading global package...";
        [[$GetFunc "rospm.reset.removeGlobal"] MetaInfo=($report->"metaScript")];
        [$LoadPackage $pkgName];
    }
    :put "The package has been upgraded.";
    :return $Nil;
}


# $downgrade
# Downgrade the package to a specific version.
# kwargs: To=<str>                          target downgradable version
# kwargs: Report=<array->str>(<report>)     package report
:local downgrade do={
    #DEFINE global
    :global Nil;
    :global IsNil;
    :global IsStrN;
    :global IsNothing;
    :global TypeofStr;
    :global TypeofArray;
    :global Replace;
    :global InValues;
    :global GetFunc;
    :global GetConfig;
    :global ReadOption;
    :global FindPackage;
    :global LoadPackage;
    :global GlobalCacheFuncRemovePrefix;
    # env
    :global EnvROSPMVersionBaseURL;
    :global EnvROSPMOwner;
    # init
    :local pkgUrl "";
    :local pkgStr "";
    :local configPkgName "config.rospm.package";
    :local config [$GetConfig $configPkgName];
    # read opt
    :local version [$ReadOption $To $TypeofStr];
    :local report [$ReadOption $Report $TypeofArray];
    # check env
    :if (![$IsStrN $EnvROSPMVersionBaseURL]) do={
        :error "rospm.action.downgrade: \$EnvROSPMVersionBaseURL is empty!";
    }
    # check params
    :if ([$IsNil $report]) do={
        :error "rospm.action.downgrade: require \$Report";
    }
    # report
    :local pkgName ($report->"package");
    :local state ($report->"state");
    :if (![$InValues "downgrade" ($report->"actions")]) do={
        :error "rospm.action.downgrade: action not found.";
    }
    # check is essential or not
    :local epkgList ($config->"essentialPackageList");
    :if ([$InValues $pkgName $epkgList]) do={
        :put "Package $pkgName is an essential package for ROSPM.";
        :put "Downgrading this package may corrupt ROSPM.";
        :error "rospm.action.downgrade: target package is essential.";
    }
    # check is downgradable
    :local versionR (($report->"metaConfig")->"version");
    :local versionL (($report->"metaScript")->"version");
    :if (($report->"configName") != $configPkgName) do={
        :error "rospm.action.downgrade: only support core package now!";
    }
    :if ($version >= $versionR) do={
        :error "rospm.action.downgrade: target version($version) is higher than the remote.";
    }
    if ($version = $versionL) do={
        :error "rospm.action.downgrade: target version($version) is same with local";
    }
    # determine pkg url
    :put "Downgrading core package $pkgName to $version(current version is $versionL)";
    :local pn [$Replace $pkgName "." "_"];
    :set pkgUrl ($EnvROSPMVersionBaseURL . "lib/$pn.rsc");
    # downloading
    :put "Get: $pkgUrl";
    :set pkgStr [[$GetFunc "tool.remote.loadRemoteSource"] URL=$pkgUrl Normalize=true];
    :put "Writing source into repository...";
    /system/script/set [$FindPackage $pkgName] source=$pkgStr owner=$EnvROSPMOwner;
    :put "Clean function cache...";
    [$GlobalCacheFuncRemovePrefix $pkgName];
    # if global, load it
    :if ((($report->"metaConfig")->"global")) do={
        :put "Loading global package...";
        [[$GetFunc "rospm.reset.removeGlobal"] MetaInfo=($report->"metaScript")];
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
    :global NewArray;
    :global GetConfig;
    :global UpdateConfig;
    :global FindPackage;
    :global GlobalCacheFuncRemovePrefix;
    # init
    :local configPkgName "config.rospm.package";
    :local configExtPkgName "config.rospm.package.ext";
    :local config [$GetConfig $configPkgName];
    # read opt
    :local report [$ReadOption $Report $TypeofArray];
    # check params
    :if ([$IsNil $report]) do={
        :error "rospm.action.remove: require \$Report";
    }
    # report
    :local pkgName ($report->"package");
    :local state ($report->"state");
    :if (![$InValues "remove" ($report->"actions")]) do={
        :error "rospm.action.remove: action not found.";
    }
    # check is essential or not
    :local epkgList ($config->"essentialPackageList");
    :if ([$InValues $pkgName $epkgList]) do={
        :put "Package $pkgName is an essential package for ROSPM.";
        :put "Removing this package will corrupt ROSPM.";
        :error "rospm.action.remove: target package is essential.";
    }
    # remove
    :put "Removing the package $pkgName...";
    /system/script/remove [$FindPackage $pkgName];
    :put "Clean function cache...";
    [$GlobalCacheFuncRemovePrefix $pkgName];
    # if global, remove it
    :if ((($report->"metaScript")->"global")) do={
        :put "Removing global functions and variables from environment...";
        [[$GetFunc "rospm.reset.removeGlobal"] MetaInfo=($report->"metaScript")];
    }
    # if local, remove it from ext
    :if ((($report->"metaScript")->"local")) do={
        :local configExt [$GetConfig $configExtPkgName];
        :local npkgMap [$NewArray ];
        :local npkgList [$NewArray ];
        :local counter 0;
        :foreach m in ($configExt->"packageList") do={
            :local mn ($m->"name");
            :if ($mn != $pkgName) do={
                :set ($npkgList->$counter) $m;
                :set ($npkgMap->$mn) $counter;
                :set counter ($counter + 1);
            }
        }
        :set ($configExt->"packageMapping") $npkgMap;
        :set ($configExt->"packageList") $npkgList;
        :put "Updating extension package list...";
        [$UpdateConfig $configExtPkgName $configExt];
    }
    :put "The package has been removed.";
    :return $Nil;
}


:local package {
    "metaInfo"=$metaInfo;
    "register"=$register;
    "install"=$install;
    "installExt"=$installExt;
    "reinstall"=$reinstall;
    "upgrade"=$upgrade;
    "downgrade"=$downgrade;
    "remove"=$remove;
}
:return $package
