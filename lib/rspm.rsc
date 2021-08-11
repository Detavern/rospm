:local metaInfo {
    "name"="rspm";
    "version"="0.0.1";
    "description"="rspm";
};


# $firstRun
# kwargs: Context=<array>       context comes from installer
:local firstRun do={
    #DEFINE global
    :global IsStr;
    :global TypeofArray;
    :global ReadOption;
    :global GetFunc;
    :global NewArray;
    :global DumpVar;
    :global CreateConfig;
    :global FindPackage;
    :global InputV;
    # local
    :local context [$ReadOption $Context $TypeofArray];
    :local configPkgName "config.rspm.package";
    :local configPkgExtName "config.rspm.package.ext";
    # check context
    :if (![$IsStr ($context->"baseURL")]) do={
        :error "rspm.firstRun: baseURL not found";
    }
    # clean local config.rspm.package
    /system script remove [$FindPackage $configPkgName];
    /system script remove [$FindPackage $configPkgExtName];
    # add resource version
    :local resVersionURL (($context->"baseURL") . "res/version.rsc");
    :local resVersion [[$GetFunc "tool.remote.loadRemoteVar"] URL=$resVersionURL];
    :set ($context->"version") $resVersion;
    # load remote package info
    :local packageInfoURL (($context->"baseURL") . "res/package-info.rsc");
    :put "Get: $packageInfoURL";
    :local packageInfo [[$GetFunc "tool.remote.loadRemoteVar"] URL=$packageInfoURL];
    # update config
    :foreach k,v in $context do={
        :set ($packageInfo->$k) $v;
    }
    # make new config.rspm.package
    [$CreateConfig $configPkgName $packageInfo Owner=($context->"owner")];
    # make new config.rspm.package.ext
    :local packageInfoExtURL (($context->"baseURL") . "res/package-info-ext.rsc");
    :local packageInfoExt [[$GetFunc "tool.remote.loadRemoteVar"] URL=$packageInfoExtURL];
    [$CreateConfig $configPkgExtName $packageInfoExt Owner=($context->"owner")];
    # check current installation
    # compare current with packagelist, and make install/upgrade advice
    :local reportList [[$GetFunc "rspm.state.checkAllState"] CheckExt=false CheckVersion=false];
    :foreach report in $reportList do={
        :local state ($report->"state");
        # remote version lt local, warn it and let user determine
        :if ($state = "LT") do={
            :local pn (($report->"metaConfig")->"name");
            :local pvr (($report->"metaConfig")->"version");
            :local pvl (($report->"metaScript")->"version");
            :put "The package $pn its remote version is $pvr, but local version is $pvl.";
            :local flag true;
            :local flagInstall false;
            :while ($flag) do={
                :local answer [$InputV "Enter [Y]es to install(downgrade to) remote version, [N]o to keep local version." ];
                :if ($answer = "Y" or $answer = "N") do={
                    :set flag false;
                    :set flagInstall ($answer = "Y");
                } else {
                    :put "Unrecognized value, input again!";
                }
            };
            # keep or not
            :if ($flagInstall) do={
                [[$GetFunc "rspm.install"] Package=$pn];
            };
        };
        # remote version gt local, let user know it will be updated
        :if ($state = "GT") do={
            :local pn (($report->"metaConfig")->"name");
            [[$GetFunc "rspm.upgrade"] Package=$pn];
        };
        :if ($state = "NES") do={
            [[$GetFunc "rspm.install"] Package=$pn];
        };
    }
    # register startup
    :local startupResURL (($context->"baseURL") . "res/startup.rsc");
    :put "Get: $startupResURL";
    :local scriptStr [[$GetFunc "tool.remote.loadRemoteSource"] URL=$startupResURL Normalize=true];
    /system scheduler remove [/system scheduler find name="rspm-startup"];
    :put "Adding rspm-startup schedule...";
    /system scheduler add name="rspm-startup" start-time=startup on-event=$scriptStr;
    :return "";
}


# $install
# kwargs: Package=<str>         package name
# kwargs: URL=<str>             package url, use for install ext package
:local install do={
    #DEFINE global
    :global IsNum;
    :global IsNothing;
    :global ReadOption;
    :global Replace;
    :global FindPackage;
    :global GetConfig;
    :global GetFunc;
    :global InValues;
    :global TypeofStr;
    :global UpdateConfig;
    :global ValidatePackageContent;
    # local
    :local pURL [$ReadOption $URL $TypeofStr ""];
    :local pkgName $Package;
    :local pkgStr "";
    :local configPkgName "config.rspm.package";
    :local configExtPkgName "config.rspm.package.ext";
    :put "Loading local configuration: $configPkgName...";
    :local config [$GetConfig $configPkgName];
    :put "Loading local configuration: $configExtPkgName...";
    :local configExt [$GetConfig $configExtPkgName];
    # check latest
    :local isLatest [[$GetFunc "rspm.state.checkVersion"] ];
    :if (!$isLatest) do={
        :error "rspm.install: local package list is out of date, please update first.";
    }
    # install by url
    :if ($pURL != "") do={
        :put "Get: $pURL";
        :set pkgStr [[$GetFunc "tool.remote.loadRemoteSource"] URL=$pURL Normalize=true];
        :local pkgFunc [:parse $pkgStr];
        :local pkg [$pkgFunc ];
        :local metaR ($pkg->"metaInfo");
        :set pkgName ($metaR->"name");
        :local metaUrl ($metaR->"url");
        :local va {"type"="code";"url"=true};
        :put "Validating package $pkgName...";
        :if (![$ValidatePackageContent $pkg $va]) do={
            :error "rspm.install: package validate failed, check log for detail";
        };
        # set proxy url
        :if ($metaUrl != $pURL) do={
            :set ($metaR->"proxyUrl") $pURL;
        }
        # check pkgName
        :if ([$IsNum (($config->"packageMapping")->$pkgName)]) do={
            :put "Same package name $pkgName found in package list.";
            :put "Using \"rspm.install\" with package name $pkgName instead.";
            :error "rspm.install: same package name.";
        }
        # update config
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
        [$UpdateConfig "config.rspm.package.ext" $configExt];
    }
    # generate report
    :put "Check package $pkgName state...";
    :local report [[$GetFunc "rspm.state.checkState"] Package=$pkgName];
    :local state ($report->"state");
    :if (![$InValues "install" ($report->"action")]) do={
        :foreach ad in ($report->"advice") do={
            :put $ad;
        }
        :error "rspm.install: state not match.";
    }
    # in available action
    :if ($state = "NES") do={
        :local versionR (($report->"metaConfig")->"version");
        :if (($report->"configName") = $configPkgName) do={
            :put "Installing core package $Package, latest version is $versionR";
            :local pkgUrl (($config->"baseURL") . "lib/$Package.rsc")
            :put "Get: $pkgUrl";
            :set pkgStr [[$GetFunc "tool.remote.loadRemoteSource"] URL=$pkgUrl Normalize=true];
        } else {
            :put "Installing extension package $Package, latest version is $versionR";
            :local pkgUrl (($report->"metaConfig")->"proxyUrl");
            :if ([$IsNothing $pkgUrl]) do={
                :set pkgUrl (($report->"metaConfig")->"url");
            }
            :if ($pkgStr = "") do={
                :put "Get: $pkgUrl";
                :set pkgStr [[$GetFunc "tool.remote.loadRemoteSource"] URL=$pkgUrl Normalize=true];
            }
        };
        :put "Writing source into repository...";
        /system script set [$FindPackage $pkgName] source=$pkgStr owner=($config->"owner");
    }
    # downgrade
    # TODO: ask continue
    :if ($state = "LT") do={
        :local versionL (($report->"metaScript")->"version");
        :local versionR (($report->"metaConfig")->"version");
        :if (($report->"configName") = $configPkgName) do={
            :put "Downgrading core package $Package, latest version is $versionR(current: $versionL)";
            :local pkgUrl (($config->"baseURL") . "lib/$Package.rsc")
            :put "Get: $pkgUrl";
            :set pkgStr [[$GetFunc "tool.remote.loadRemoteSource"] URL=$pkgUrl Normalize=true];
        } else {
            :put "Downgrading extension package $Package, latest version is $versionR(current: $versionL)";
            :local pkgUrl (($report->"metaConfig")->"proxyUrl");
            :if ([$IsNothing $pkgUrl]) do={
                :set pkgUrl (($report->"metaConfig")->"url");
            }
            :if ($pkgStr = "") do={
                :put "Get: $pkgUrl";
                :set pkgStr [[$GetFunc "tool.remote.loadRemoteSource"] URL=$pkgUrl Normalize=true];
            }
        };
        :put "Writing source into repository...";
        /system script set [$FindPackage $pkgName] source=$pkgStr owner=($config->"owner");
    }
    # reinstall
    # TODO: ask continue
    :if ($state = "SAME") do={
        :local versionR (($report->"metaConfig")->"version");
        :if (($report->"configName") = $configPkgName) do={
            :put "Reinstalling core package $Package, latest version is $versionR";
            :local pkgUrl (($config->"baseURL") . "lib/$Package.rsc")
            :put "Get: $pkgUrl";
            :set pkgStr [[$GetFunc "tool.remote.loadRemoteSource"] URL=$pkgUrl Normalize=true];
        } else {
            :put "Reinstalling extension package $Package, latest version is $versionR";
            :local pkgUrl (($report->"metaConfig")->"proxyUrl");
            :if ([$IsNothing $pkgUrl]) do={
                :set pkgUrl (($report->"metaConfig")->"url");
            }
            :if ($pkgStr = "") do={
                :put "Get: $pkgUrl";
                :set pkgStr [[$GetFunc "tool.remote.loadRemoteSource"] URL=$pkgUrl Normalize=true];
            }
        };
        :put "Writing source into repository...";
        /system script set [$FindPackage $pkgName] source=$pkgStr owner=($config->"owner");
    }
    :put "The package has been installed.";
    # if global, run it
    :if ((($report->"metaConfig")->"global") = true) do={
        :local fileName [$Replace $pkgName "." "_"];
        :local cmdStr "/system script run [/system script find name=\"$fileName\"];";
        :local cmdFunc [:parse $cmdStr];
        [$cmdFunc ];
    }
    :return "";
}


# $update
# update local package configuration file
# kwargs: Package=<str>         package name
:local update do={
    #DEFINE global
    :global IsNothing;
    :global GetConfig;
    :global GetFunc;
    :global UpdateConfig;
    :global NewArray;
    :global InKeys;
    :global SetGlobalVar;
    :global ValidatePackageContent;
    # local
    :local configPkgName "config.rspm.package";
    :local configExtPkgName "config.rspm.package.ext";
    :put "Loading local configuration: $configPkgName...";
    :local config [$GetConfig $configPkgName];
    :put "Loading local configuration: $configExtPkgName...";
    :local configExt [$GetConfig $configExtPkgName];
    :local version ($config->"version");
    :local newConfigExt;
    # add resource version
    :local resVersionURL (($config->"baseURL") . "res/version.rsc");
    :put "Get: $resVersionURL";
    :local resVersion [[$GetFunc "tool.remote.loadRemoteVar"] URL=$resVersionURL];
    [$SetGlobalVar "RSPMRemoteVersion" $resVersion Timeout=00:30:00];
    # check core
    :put "Checking core packages...";
    :if ($version >= $resVersion) do={
        :put "RSPM packages already up-to-date";
        :set newConfigExt $configExt;
    } else {
        :put "Latest version is $resVersion, your current version is $version";
        # update package-info
        :local packageInfoURL (($config->"baseURL") . "res/package-info.rsc");
        :put "Get: $packageInfoURL";
        :local packageInfo [[$GetFunc "tool.remote.loadRemoteVar"] URL=$packageInfoURL];
        :put "Updating local configuration: $configPkgName...";
        :foreach k,v in $packageInfo do={
            :set ($config->$k) $v;
        }
        :set ($config->"version") $resVersion;
        [$UpdateConfig $configPkgName $config];
        # update package-info-ext
        :local packageInfoExtURL (($config->"baseURL") . "res/package-info-ext.rsc");
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
        :local startupResURL (($config->"baseURL") . "res/startup.rsc");
        :put "Get: $startupResURL";
        :local scriptStr [[$GetFunc "tool.remote.loadRemoteSource"] URL=$startupResURL Normalize=true];
        /system scheduler remove [/system scheduler find name="rspm-startup"];
        :put "Adding rspm-startup schedule...";
        /system scheduler add name="rspm-startup" start-time=startup on-event=$scriptStr;
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
}

# $upgrade
# upgrade package according to local package list.
# kwargs: Package=<str>         package name
:local upgrade do={
    #DEFINE global
    :global IsStr;
    :global IsNothing;
    :global InValues;
    :global FindPackage;
    :global GetFunc;
    :global GetConfig;
    # local
    :local configPkgName "config.rspm.package";
    :put "Loading local configuration: $configPkgName...";
    :local config [$GetConfig $configPkgName];
    # generate report
    :put "Check package $Package state...";
    :local report [[$GetFunc "rspm.state.checkState"] Package=$Package];
    :local state ($report->"state");
    :if (![$InValues "upgrade" ($report->"action")]) do={
        :foreach ad in ($report->"advice") do={
            :put $ad;
        }
        :error "rspm.upgrade: state not match.";
    }
    # in available action
    :if ($state = "GT") do={
        :local pkgUrl;
        :local versionR (($report->"metaConfig")->"version");
        :local versionL (($report->"metaScript")->"version");
        :if (($report->"configName") = $configPkgName) do={
            :put "Upgrading core package $Package, latest version is $versionR(current: $versionL)";
            :local isLatest [[$GetFunc "rspm.state.checkVersion"] ];
            :if (!$isLatest) do={
                :error "rspm.upgrade: local package list is out of date, please update first.";
            }
            :set pkgUrl (($config->"baseURL") . "lib/$Package.rsc")
        } else {
            :put "Upgrading extension package $Package, latest version is $versionR(current: $versionL)";
            :set pkgUrl (($report->"metaConfig")->"proxyUrl");
            :if ([$IsNothing $pkgUrl]) do={
                :set pkgUrl (($report->"metaConfig")->"url");
            }
        }
        :put "Get: $pkgUrl";
        :local pkgStr [[$GetFunc "tool.remote.loadRemoteSource"] URL=$pkgUrl Normalize=true];
        :put "Writing source into repository...";
        /system script set [$FindPackage $Package] source=$pkgStr owner=($config->"owner");
    }
    :put "The package has been upgraded.";
}


# $remove
# remove an installed package from local repository.
# kwargs: Package=<str>         package name
:local remove do={
    #DEFINE global
    :global GetFunc;
    :global GetConfig;
    :global InValues;
    :global FindPackage;
    # local
    :local configPkgName "config.rspm.package";
    :put "Loading local configuration: $configPkgName...";
    :local config [$GetConfig $configPkgName];
    # generate report
    :put "Check package $Package state...";
    :local report [[$GetFunc "rspm.state.checkState"] Package=$Package];
    :local state ($report->"state");
    :if (![$InValues "remove" ($report->"action")]) do={
        :foreach ad in ($report->"advice") do={
            :put $ad;
        }
        :error "rspm.upgrade: state not match.";
    }
    # in available action
    :local epkgList ($config->"essentialPackageList");
    :if ([$InValues $Package $epkgList]) do={
        :put "Package $Package is an essential package for RSPM.";
        :put "Removing this package will corrupt RSPM.";
        :error "rspm.upgrade: package is essential";
    } else {
        :put "Removing the package $Package...";
        /system script remove [$FindPackage $Package];
        :put "The package has been removed.";
    }
}


# $register
# register a local package into package manager.
# kwargs: Package=<str>         package name
:local register do={
    #DEFINE global
    :global GetFunc;
    :global GetConfig;
    :global InValues;
    :global UpdateConfig;
    # local
    :local configPkgName "config.rspm.package";
    :local configExtPkgName "config.rspm.package.ext";
    :put "Loading local configuration: $configPkgName...";
    :local config [$GetConfig $configPkgName];
    :put "Loading local configuration: $configExtPkgName...";
    :local configExt [$GetConfig $configExtPkgName];
    # generate report
    :put "Check package $Package state...";
    :local report [[$GetFunc "rspm.state.checkState"] Package=$Package];
    :local state ($report->"state");
    :if (![$InValues "register" ($report->"action")]) do={
        :foreach ad in ($report->"advice") do={
            :put $ad;
        }
        :error "rspm.upgrade: state not match.";
    }
    # in available action
    :if ($state = "NEC") do={
        :local meta ($report->"metaScript");
        :local pkgName ($meta->"name");
        :local ml ($configExt->"packageList");
        :local mp ($configExt->"packageMapping");
        :set ($mp->$pkgName) [:len $ml];
        :set ($ml->[:len $ml]) $meta;
        :put "Updating extension package list...";
        [$UpdateConfig $configExtPkgName $configExt];
    };
    :put "The package has been registed.";
}


# $upgradeAll
:local upgradeAll do={
    #DEFINE global
    :global IsNothing;
    :global GetFunc;
    :global GetConfig;
    :global InValues;
    :global NewArray;
    :global FindPackage;
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
        :error "rspm.upgrade: local package list is out of date, please update first.";
    }
    # generate upgrade list
    :local reportList [[$GetFunc "rspm.state.checkAllState"] ];
    :local upgradeList [$NewArray ];
    :foreach report in $reportList do={
        :if ([$InValues "upgrade" ($report->"action")]) do={
            :set ($upgradeList->[:len $upgradeList]) $report;
        }
    };
    # do upgrade
    :local lenUpradeList [:len $upgradeList];
    :put "$lenUpradeList packages need upgrade.";  
    :foreach report in $upgradeList do={
        :local state ($report->"state");
        :if ($state = "GT") do={
            :if (($report->"configName") = $configPkgName) do={
                :local versionR (($report->"metaConfig")->"version");
                :put "Upgrading core package $Package, latest version is $versionR";
                :local pkgUrl (($config->"baseURL") . "lib/$Package.rsc")
                :put "Get: $pkgUrl";
                :local pkgStr [[$GetFunc "tool.remote.loadRemoteSource"] URL=$pkgUrl Normalize=true];
                :put "Writing source into repository...";
                /system script set [$FindPackage $Package] source=$pkgStr owner=($config->"owner");
            } else {
                :local versionR (($report->"metaConfig")->"version");
                :put "Upgrading extension package $Package, latest version is $versionR";
                :local pkgUrl (($report->"metaConfig")->"proxyUrl");
                :if ([$IsNothing $pkgUrl]) do={
                    :set pkgUrl (($report->"metaConfig")->"url");
                }
                :put "Get: $pkgUrl";
                :local pkgStr [[$GetFunc "tool.remote.loadRemoteSource"] URL=$pkgUrl Normalize=true];
                :put "Writing source into repository...";
                /system script set [$FindPackage $Package] source=$pkgStr owner=($config->"owner");
            }
        }
    };
    :put "$lenUpradeList packages have been upgraded.";  
}


:local package {
    "metaInfo"=$metaInfo;
    "firstRun"=$firstRun;
    "install"=$install;
    "update"=$update;
    "upgrade"=$upgrade;
    "remove"=$remove;
    "register"=$register;
    "upgradeAll"=$upgradeAll;
}
:return $package;
