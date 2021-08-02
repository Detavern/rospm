:local metaInfo {
    "name"="rspm";
    "version"="0.0.1";
    "description"="rspm";
};


# $loadRemoteScript
# load remote script from url and put into strings
# kwargs: URL=<str>                 url of remote script
# opt kwargs: Normalize=<bool>      false(default), normalize the eol by "\r\n"
# return: <str>             remote script
:local loadRemoteScript do={
    #DEFINE global
    :global Split;
    :global Join;
    :global Strip;
    :global NewArray;
    :global ReadOption;
    :global TypeofBool;
    :global TypeofStr;
    :global GetFunc;
    :global ScriptLengthLimit;
    # local
    :local pNormalize [$ReadOption $Normalize $TypeofBool false];
    :local pURL [$ReadOption $URL $TypeofStr ""];
    :local result;
    :if ($pURL = "") do={
        :error "rspm.loadRemoteScript: need \$URL",
    }
    # get source
    :local resp [[$GetFunc "tool.http.httpGet"] URL=$pURL];
    :if ($pNormalize) do={
        :local splitted [$Split ($resp->"data") ("\n")];
        :local stripList [$NewArray];
        :foreach line in $splitted do={
            :local sc {("\r")};
            :local lineS [$Strip $line $sc];
            :set ($stripList->[:len $stripList]) $lineS;
        };
        :set result [$Join ("\r\n") $stripList];
    } else {
        :set result ($resp->"data");
    };
    :local lenResult [:len $result];
    :if ($lenResult > $ScriptLengthLimit) do={
        :error "rspm.loadRemoteScript: package string length($lenResult) exceed limit";
    }
    :return $result;
}


# $checkPackageState
# opt kwargs: CheckExt=<bool>       default true, check custom packages or not
# return: <array->str>
:local checkPackageState do={
    #DEFINE global
    :global IsStr;
    :global IsNil;
    :global TypeofBool;
    :global TypeofArray;
    :global ReadOption;
    :global GetConfig;
    :global GetMeta;
    :global NewArray;
    :global StartsWith;
    :global LoadVar;
    # local
    :local configPkgName "config.rspm.package";
    :local pCheckExt [$ReadOption $CheckExt $TypeofBool true];
    :local config [$GetConfig $configPkgName];
    :local pkgMapping ($config->"PackageMapping");
    :local pkgList ($config->"PackageList");
    :local scriptOwner ($config->"Owner");
    # check installed package
    :local pkgVerEqList [$NewArray ];
    :local pkgVerGtList [$NewArray ];
    :local pkgVerLtList [$NewArray ];
    :local pkgPendingList [$NewArray ];
    # custom package
    :local cpkgVerEqList [$NewArray ];
    :local cpkgVerGtList [$NewArray ];
    :local cpkgVerLtList [$NewArray ];
    :local pkgIDList [/system script find owner=$scriptOwner];
    :foreach i in $pkgIDList do={
        :local flag false;
        :local metaL;
        # load metaL from package
        :do {
            :set metaL [$GetMeta ID=$i];
            :local nameL ($metaL->"name");
            :if (![$StartsWith $nameL "config."] and ![$StartsWith $nameL "env."]) do={
                :set flag true;
            }
        } on-error {
            :local fileName [/system script get $i name];
            :if ([$IsNil $fileName]) do={
                :log warning "rspm.checkPackageStatus: could not find package id=$i";
            } else {
                :log warning "rspm.checkPackageStatus: could not load package name=$fileName, maybe corrupt, this package will be removed";
                /system script remove numbers=$i;
            }
        }
        # load metaR from local config
        :if ($flag) do={
            :local rpkgID ($pkgMapping->($metaL->"name"));
            :if ([$IsNothing $rpkgID]) do={
                :if ($pCheckExt) do={
                # TODO: custom package
                }
            } else {
                :set ($pkgMapping->($metaL->"name")) -1;
                :local metaR ($pkgList->$rpkgID);
                :local versionL ($metaL->"version");
                :local versionR ($metaR->"version");
                :local cmp [$NewArray ];
                :set ($cmp->"remote") $metaR;
                :set ($cmp->"local") $metaL;
                :if ($versionR = $versionL) do={
                    :set ($pkgVerEqList->[:len $pkgVerEqList]) $cmp;
                } else {
                    :if ($versionR > $versionL) do={
                        :set ($pkgVerGtList->[:len $pkgVerGtList]) $cmp;
                    } else {
                        :set ($pkgVerLtList->[:len $pkgVerLtList]) $cmp;
                    };
                };
            };
        };
    }
    # make install pending list
    :foreach v in $pkgList do={
        :local name ($v->"name");
        :if (($pkgMapping->$name) >= 0) do={
            :set ($pkgPendingList->[:len $pkgPendingList]) $v;
        };
    }
    # read package state
    :put "Reading package state information...";
    :local lenPkgLt [:len $pkgVerLtList];
    :if ($lenPkgLt > 0) do={
        :put "$lenPkgLt packages have unknown version number, please check these packages!";
        :foreach v in $pkgVerLtList do={
            :local pn (($v->"remote")->"name");
            :local pvr (($v->"remote")->"version");
            :local pvl (($v->"local")->"version");
            :put "    package: $pn, remote version: $pvr, local version: $pvl";
        };
    };
    :local lenPkgGt [:len $pkgVerGtList];
    :put "$lenPkgGt packages can be upgraded.";
    :foreach v in $pkgVerGtList do={
        :local pn (($v->"remote")->"name");
        :local pvr (($v->"remote")->"version");
        :local pvl (($v->"local")->"version");
        :put "    package: $pn, remote version: $pvr, local version: $pvl";
    };
    :local lenPkgEq [:len $pkgVerEqList];
    :put "$lenPkgEq packages have up to date.";
    :local lenPkgPending [:len $pkgPendingList];
    :put "$lenPkgPending packages need install.";
    :foreach v in $pkgPendingList do={
        :local pn ($v->"name");
        :local pv ($v->"version");
        :put "    package: $pn, remote version: $pv";
    };

    # result
    :local result [$NewArray ];
    :set ($result->"pkgVerEqList") $pkgVerEqList;
    :set ($result->"pkgVerGtList") $pkgVerGtList;
    :set ($result->"pkgVerLtList") $pkgVerLtList;
    :set ($result->"pkgPendingList") $pkgPendingList;
    :set ($result->"cpkgVerEqList") $cpkgVerEqList;
    :set ($result->"cpkgVerGtList") $cpkgVerGtList;
    :set ($result->"cpkgVerLtList") $cpkgVerLtList;
    :return $result;
}


# $firstRun
# kwargs: Context=<array>       context comes from installer
:local firstRun do={
    #DEFINE global
    :global IsStr;
    :global TypeofArray;
    :global ReadOption;
    :global GetFunc;
    :global NewArray;
    :global LoadVar;
    :global DumpVar;
    :global CreateConfig;
    :global FindPackage;
    :global InputV;
    # local
    :local context [$ReadOption $Context $TypeofArray];
    :local configPkgName "config.rspm.package";
    # check context
    :if (![$IsStr ($context->"BaseURL")]) do={
        :error "rspm.firstRun: BaseURL not found";
    }
    # clean local config.rspm.package
    /system script remove [$FindPackage $configPkgName];
    # make new config array
    :set ($context->"PackageList") "noquote:\$packageList";
    :set ($context->"PackageMapping") "noquote:\$packageMapping";
    # load remote package info
    :local packageInfoURL (($context->"BaseURL") . "res/package-info.rsc");
    :put "Get: $packageInfoURL";
    :local resp [[$GetFunc "tool.http.httpGet"] URL=$packageInfoURL];
    :local packageInfo [$LoadVar ($resp->"data")];
    # make new config.rspm.package
    [$CreateConfig $configPkgName $context $packageInfo Owner=($context->"Owner")];
    # check current installation
    # compare current with packagelist, and make install/upgrade advice
    :local report [[$GetFunc "rspm.checkPackageState"] CheckExt=false];
    # remote version lt local, warn it and let user determine
    :foreach v in ($report->"pkgVerLtList") do={
        :local pn (($v->"remote")->"name");
        :local pvr (($v->"remote")->"version");
        :local pvl (($v->"local")->"version");
        :put "Package: $pn, its remote version is $pvr, but local version is $pvl.";
        :local flag true;
        :local flagKeep false;
        :while ($flag) do={
            :local answer [$InputV "Enter [Y]es to use remote version, [N]o to keep local version." ];
            :if ($answer = "Y" or $answer = "N") do={
                :set flag false;
                :set flagKeep $answer;
            } else {
                :put "Unrecognized value, input again!";
            }
        };
        # keep or not
        :if (!$flagKeep) do={
            /system script remove [$FindPackage $pn];
            [[$GetFunc "rspm.install"] Package=$pn];
        };
    };
    # remote version gt local, let user know it will be updated
    :foreach v in ($report->"pkgVerGtList") do={
        :local pn (($v->"remote")->"name");
        [[$GetFunc "rspm.upgrade"] Package=$pn];
    };
    # remote version eq local, keep silence
    # install pending package
    :foreach v in ($report->"pkgPendingList") do={
        :local pn ($v->"name");
        /system script remove [$FindPackage $pn];
        [[$GetFunc "rspm.install"] Package=$pn];
    }
    # register startup
    :local startupResURL (($context->"BaseURL") . "res/startup.rsc");
    :put "Get: $startupResURL";
    :local scriptStr [[$GetFunc "rspm.loadRemoteScript"] URL=$startupResURL Normalize=true];
    /system scheduler remove [/system scheduler find name="rspm-startup"];
    :put "Adding rspm-startup schedule...";
    /system scheduler add name="rspm-startup" start-time=startup on-event=$scriptStr;
    :return "";
}


# $install
# kwargs: Package=<str>         package name
# kwargs: URL=<str>             package url
:local install do={
    #DEFINE global
    :global IsNothing;
    :global ReadOption;
    :global StartsWith;
    :global Replace;
    :global FindPackage;
    :global GetConfig;
    :global GetFunc;
    :global TypeofStr;
    :global ScriptLengthLimit;
    :global ValidatePackageContent;
    # local
    :local pURL [$ReadOption $URL $TypeofStr ""];
    :local pkgName $Package;
    :local pkgStr "";
    :local config [$GetConfig "config.rspm.package"];
    :if ([$IsNothing $pkgName] and ($pURL = "")) do={
        :error "rspm.install: need either \$Package or \$URL";
    }
    :if (![$IsNothing $pkgName]) do={
        :local pkgMapping ($config->"PackageMapping");
        :if ([$IsNothing ($pkgMapping->$pkgName)]) do={
            :error "rspm.install: \$Package not found in list, try update and install again."
        }
        :local path [$Replace $pkgName "." "_"];
        :local url (($config->"BaseURL") . "lib/$path.rsc");
        # get pkgstr
        :put "Get: $url";
        :set pkgStr [[$GetFunc "rspm.loadRemoteScript"] URL=$url Normalize=true];
        :local pkgFunc [:parse $pkgStr];
        :local pkg [$pkgFunc ];
        :local va {"name"=$pkgName;"type"="code"};
        :put "Validating package $pkgName...";
        :if (![$ValidatePackageContent $pkg $va]) do={
            :error "rspm.install: package validate failed, check log for detail";
        };
    }
    :if ($pURL != "") do={
        :if (![$StartsWith $pURL "http://"] and ![$StartsWith $pURL "https://"]) do={
            :error "rspm.install: url scheme not supported";
        }
        # get pkgstr
        :put "Get: $pURL";
        :set pkgStr [[$GetFunc "rspm.loadRemoteScript"] URL=$pURL Normalize=true];
        :local pkgFunc [:parse $pkgStr];
        :local pkg [$pkgFunc ];
        :local va {"type"="code"};
        :put "Validating package $pkgName...";
        :if (![$ValidatePackageContent $pkg $va]) do={
            :error "rspm.install: package validate failed, check log for detail";
        };
        :local meta ($pkg->"metaInfo");
        :set pkgName ($meta->"name");
    }
    # same package
    :local pl [$FindPackage $pkgName];
    :if ([:len $pl] > 0) do={
        :error "rspm.install: package already exist";
    };
    # write into repository
    :local fileName [$Replace $pkgName "." "_"];
    :put "Adding package to local repository...";
    /system script add name=$fileName source=$pkgStr owner=($config->"Owner");
    :put "Package $pkgName installed.";
    :return "";
}


# $update
# kwargs: Package=<str>         package name
:local update do={
    #DEFINE global
    :global IsNil;
    :global IsNothing;

}

# $upgrade
# kwargs: Package=<str>         package name
:local upgrade do={
    #DEFINE global
    :global IsNil;
    :global IsNothing;

}


# $upgradeAll
:local upgradeAll do={
    #DEFINE global
    :global IsNil;
    :global IsNothing;

}


:local package {
    "metaInfo"=$metaInfo;
    "loadRemoteScript"=$loadRemoteScript;
    "checkPackageState"=$checkPackageState;
    "firstRun"=$firstRun;
    "install"=$install;
    "update"=$update;
    "upgrade"=$upgrade;
    "upgradeAll"=$upgradeAll;
}
:return $package;
