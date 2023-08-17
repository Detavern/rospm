#!rsc by RouterOS
# ===================================================================
# |       RSPM Packages      |   rspm
# ===================================================================
# ALL package level functions follows lower camel case.
# rspm entry
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rspm/blob/master/LICENSE.md
#
:local metaInfo {
    "name"="rspm";
    "version"="0.4.1";
    "description"="rspm entry";
};


# $firstRun
# kwargs: Context=<array>       context comes from installer
:local firstRun do={
    #DEFINE global
    :global Nil;
    :global TypeofArray;
    :global ReadOption;
    :global GetFunc;
    :global InValues;
    :global InputV;
    # local
    :local context [$ReadOption $Context $TypeofArray];
    # get remote version
    :local versionURL (($context->"RSPMBaseURL") . "res/version.rsc");
    :local version [[$GetFunc "tool.remote.loadRemoteVar"] URL=$versionURL];
    :set ($context->"RSPMVersion") $version;
    # init config
    [[$GetFunc "rspm.config.initConfig"]];
    [[$GetFunc "rspm.config.initPackageConfig"] Context=$context];
    [[$GetFunc "rspm.config.initPackageExtConfig"]];
    # check current installation
    # compare current with packagelist, and make install/upgrade advice
    :local reportList [[$GetFunc "rspm.state.checkAllState"] CheckExt=false CheckVersion=false];
    :foreach report in $reportList do={
        :local state ($report->"state");
        # remote version lt local, warn it and let user determine
        :if ($state = "LT") do={
            :local answer [$InputV ("Remote version is lower than the local. Enter yes to downgrade.") Default=no];
            :if ($answer) do={
                [[$GetFunc "rspm.action.downgrade"] Report=$report];
            }
        };
        # remote version gt local, let user know it will be updated
        :if ($state = "GT") do={
            [[$GetFunc "rspm.action.upgrade"] Report=$report];
        };
        # not exist in local repository, use config to install it
        :if ($state = "NES") do={
            :local pn (($report->"metaConfig")->"name");
            :local epkgList ($packageInfo->"essentialPackageList");
            :if ([$InValues $pn $epkgList]) do={
                [[$GetFunc "rspm.action.install"] Report=$report];
            }
        };
    }
    # register startup
    :local startupName "RSPM_STARTUP";
    :local startupResURL (($context->"RSPMBaseURL") . "res/startup.rsc");
    :put "Get: $startupResURL";
    :local scriptStr [[$GetFunc "tool.remote.loadRemoteSource"] URL=$startupResURL Normalize=true];
    /system/scheduler/remove [/system/scheduler/find name=$startupName];
    :put "Adding $startupName schedule...";
    # add scheduler use default policy
    /system/scheduler/add name=$startupName start-time=startup on-event=$scriptStr;
    :return $Nil;
}


# $update
# Update local package configuration file.
# kwargs: Package=<str>         package name
:local update do={
    #DEFINE global
    :global Nil;
    :global IsNothing;
    :global NewArray;
    :global GetFunc;
    :global GetConfig;
    :global UpdateConfig;
    :global InKeys;
    :global ValidatePackageContent;
    # env
    :global EnvRSPMBaseURL;
    :global EnvRSPMVersion;
    # local
    :local configPkgName "config.rspm.package";
    :local configExtPkgName "config.rspm.package.ext";
    :put "Loading local configuration: $configPkgName...";
    :local config [$GetConfig $configPkgName];
    :put "Loading local configuration: $configExtPkgName...";
    :local configExt [$GetConfig $configExtPkgName];
    :local version $EnvRSPMVersion;
    :local newConfigExt;
    # add resource version
    :local resVersionURL ($EnvRSPMBaseURL . "res/version.rsc");
    :put "Get: $resVersionURL";
    :local resVersion [[$GetFunc "tool.remote.loadRemoteVar"] URL=$resVersionURL];
    # check core
    :put "Checking core packages...";
    :if ($version >= $resVersion) do={
        :put "RSPM packages already up-to-date";
        :set newConfigExt $configExt;
    } else {
        :put "Latest version is $resVersion, your current version is $version";
        # update package-info
        :local packageInfoURL ($EnvRSPMBaseURL . "res/package-info.rsc");
        :put "Get: $packageInfoURL";
        :local packageInfo [[$GetFunc "tool.remote.loadRemoteVar"] URL=$packageInfoURL];
        :put "Updating local configuration: $configPkgName...";
        :foreach k,v in $packageInfo do={
            :set ($config->$k) $v;
        }
        :set (($config->"environment")->"RSPMVersion") $resVersion;
        [$UpdateConfig $configPkgName $config];
        # update package-info-ext
        :local packageInfoExtURL ($EnvRSPMBaseURL . "res/package-info-ext.rsc");
        :put "Get: $packageInfoExtURL";
        :local packageInfoExt [[$GetFunc "tool.remote.loadRemoteVar"] URL=$packageInfoExtURL];
        :set newConfigExt $packageInfoExt;
        :local ml ($newConfigExt->"packageList");
        :local mp ($newConfigExt->"packageMapping");
        # add local ext pkg into new
        :foreach k,v in ($configExt->"packageMapping") do={
            :if (![$InKeys $k $mp]) do={
                :local m (($configExt->"packageList")->$v);
                :set ($mp->($m->"name")) [:len $ml];
                :set ($ml->[:len $ml]) $m;
            }
        }
        # update startup scheduler
        :local startupName "RSPM_STARTUP";
        :local startupResURL ($EnvRSPMBaseURL . "res/startup.rsc");
        :put "Get: $startupResURL";
        :local scriptStr [[$GetFunc "tool.remote.loadRemoteSource"] URL=$startupResURL Normalize=true];
        /system/scheduler/remove [/system/scheduler/find name=$startupName];
        :put "Adding rspm-startup schedule...";
        # add scheduler use default policy
        /system/scheduler/add name=$startupName start-time=startup on-event=$scriptStr;
    }
    # check ext
    :local counter 0;
    :put "Checking extension packages...";
    :foreach meta in ($newConfigExt->"packageList") do={
        :local pkgURL;
        :if ([$IsNothing ($meta->"proxyUrl")]) do={
            :set pkgURL ($meta->"url"); 
        } else {
            :set pkgURL ($meta->"proxyUrl"); 
        }
        :local extName ($meta->"name");
        :local extVerL ($meta->"version");
        # load remote package check version
        :put "Get: $pkgURL";
        :local pkgExt [[$GetFunc "tool.remote.loadRemoteVar"] URL=$pkgURL];
        # check pkg
        :local va {"type"="code";"name"=($meta->"name");"url"=true};
        :if (![$ValidatePackageContent $pkgExt $va]) do={
            :put "Error occured when loading remote resource of $extName, check log for detail";
        } else {
            :local extVerR (($pkgExt->"metaInfo")->"version");
            :if ($extVerL < $extVerR) do={
                :set counter ($counter+1);
                :foreach k,v in ($pkgExt->"metaInfo") do={
                    :set ($meta->$k) $v;
                }
            }
        }
    }
    # update ext config
    :put "$counter extension packages need upgrade";
    :put "Updating local configuration: $configExtPkgName...";
    [$UpdateConfig $configExtPkgName $newConfigExt];
    :put "The package list has been updated.";
    :return $Nil;
}


# $register
# kwargs: Package=<str>         package name
:local register do={
    #DEFINE global
    :global Nil;
    :global GetFunc;
    # opt
    :local pkgName $Package;
    # generate report
    :put "Check package $pkgName state...";
    :local report [[$GetFunc "rspm.state.checkState"] Package=$pkgName];
    :local state ($report->"state");
    # register
    :if ($state = "NEC") do={
        [[$GetFunc "rspm.action.register"] Report=$report];
        :return $Nil;
    }
    # fallback
    :foreach ad in ($report->"advice") do={
        :put $ad;
    }
    :error "rspm.register: state not match.";
}


# $install
# kwargs: Package=<str>             package name
# kwargs: URL=<str>                 package url, use for install ext package
# opt kwargs: Suggestion=<bool>     use suggestion or not
:local install do={
    #DEFINE global
    :global Nil;
    :global InputV;
    :global GetFunc;
    :global ReadOption;
    :global TypeofStr;
    :global TypeofBool;
    # opt
    :local pkgName $Package;
    :local pURL [$ReadOption $URL $TypeofStr ""];
    :local pSuggestion [$ReadOption $Suggestion $TypeofBool yes];
    # TODO: use specific version
    :local isLatest [[$GetFunc "rspm.state.checkVersion"] ];
    :if (!$isLatest) do={
        :error "rspm.install: local package list is out of date, please update first.";
    }
    # register ext package by url
    :if ($pURL != "") do={
        [[$GetFunc "rspm.action.registerExt"] URL=$pURL];
    }
    # generate report
    :put "Check package $pkgName state...";
    :local report [[$GetFunc "rspm.state.checkState"] Package=$pkgName];
    :local state ($report->"state");
    # install
    :if ($state = "NES") do={
        [[$GetFunc "rspm.action.install"] Report=$report];
        :return $Nil;
    }
    # suggest downgrading the package
    :if ($state = "LT") do={
        :if ($pSuggestion) do={
            :local answer [$InputV ("Remote version is lower than the local. Enter yes to downgrade.") Default=no];
            :if ($answer) do={
                [[$GetFunc "rspm.action.downgrade"] Report=$report];
                :return $Nil;
            }
        }
        :put "Package $pkgName already exist, could be downgrade, skipped...";
        :return $Nil;
    }
    # suggest reinstalling the package
    :if ($state = "SAME") do={
        :if ($pSuggestion) do={
            :local answer [$InputV ("Remote version is equal to the local. Enter yes to reinstall.") Default=no];
            :if ($answer) do={
                [[$GetFunc "rspm.action.reinstall"] Report=$report];
                :return $Nil;
            }
        }
        :put "Package $pkgName already exist, could be reinstall, skipped...";
        :return $Nil;
    }
    # fallback
    :foreach ad in ($report->"advice") do={
        :put $ad;
    }
    :error "rspm.install: state not match.";
}


# $remove
# kwargs: Package=<str>         package name
:local remove do={
    #DEFINE global
    :global Nil;
    :global GetFunc;
    :global GetConfig;
    # local
    :local configPkgName "config.rspm.package";
    :put "Loading local configuration: $configPkgName...";
    :local config [$GetConfig $configPkgName];
    # opt
    :local pkgName $Package;
    # generate report
    :put "Check package $pkgName state...";
    :local report [[$GetFunc "rspm.state.checkState"] Package=$pkgName];
    :local state ($report->"state");
    # comment if not installed
    :if ($state = "NES") do={
        :put "Package $pkgName has not yet installed.";
        :error "rspm.remove: state not match.";
    }
    # comment to register it first
    :if ($state = "NEC") do={
        :put "Package $pkgName found, but it is an orphaned one. You should register it first.";
        :error "rspm.remove: state not match.";
    }
    # remove
    [[$GetFunc "rspm.action.remove"] Report=$report];
    :return $Nil;
}


# $upgrade
# kwargs: Package=<str>         package name
:local upgrade do={
    #DEFINE global
    :global Nil;
    :global GetFunc;
    # opt
    :local pkgName $Package;
    # generate report
    :put "Check package $pkgName state...";
    :local report [[$GetFunc "rspm.state.checkState"] Package=$pkgName];
    :local state ($report->"state");
    # upgrade
    :if ($state = "GT") do={
        [[$GetFunc "rspm.action.upgrade"] Report=$report];
        :return $Nil;
    }
    # fallback
    :foreach ad in ($report->"advice") do={
        :put $ad;
    }
    :error "rspm.upgrade: state not match.";
}


# $upgradeAll
:local upgradeAll do={
    #DEFINE global
    :global Nil;
    :global IsNothing;
    :global GetFunc;
    :global GetConfig;
    :global InValues;
    :global NewArray;
    :global FindPackage;
    :global LoadPackage;
    :global GlobalCacheFuncFlush;
    # env
    :global EnvRSPMBaseURL;
    :global EnvRSPMOwner;
    # local
    :local configPkgName "config.rspm.package";
    :local configExtPkgName "config.rspm.package.ext";
    :put "Loading local configuration: $configPkgName...";
    :local config [$GetConfig $configPkgName];
    :put "Loading local configuration: $configExtPkgName...";
    :local configExt [$GetConfig $configExtPkgName];
    # check latest
    :local isLatest [[$GetFunc "rspm.state.checkVersion"] ];
    :if (!$isLatest) do={
        :error "rspm.upgradeAll: local package list is out of date, please update first.";
    }
    # generate upgrade list
    :local reportList [[$GetFunc "rspm.state.checkAllState"] ];
    :local upgradeList [$NewArray ];
    :foreach report in $reportList do={
        :if (($report->"state") = "GT") do={
            :set ($upgradeList->[:len $upgradeList]) $report;
        }
    };
    # do upgrade
    :local lenUpradeList [:len $upgradeList];
    :put "$lenUpradeList packages need upgrade.";
    :foreach report in $upgradeList do={
        [[$GetFunc "rspm.action.upgrade"] Report=$report];
    };
    :put "$lenUpradeList packages have been upgraded.";
    :return $Nil;
}


:local package {
    "metaInfo"=$metaInfo;
    "firstRun"=$firstRun;
    "update"=$update;
    "register"=$register;
    "install"=$install;
    "remove"=$remove;
    "upgrade"=$upgrade;
    "upgradeAll"=$upgradeAll;
}
:return $package;
