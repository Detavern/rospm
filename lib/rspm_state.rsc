#!rsc by RouterOS
# ===================================================================
# |       RSPM Packages      |   rspm.state
# ===================================================================
# ALL package level functions follows lower camel case.
# RSPM package state tools
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rspm/blob/master/LICENSE.md
#
:local metaInfo {
    "name"="rspm.state";
    "version"="0.4.2";
    "description"="RSPM package state tools";
};


# $checkVersion
# Check if the package list version is up-to-date.
# opt kwargs: ForceUpdate=<bool>        false(default), force reload remote version
# return: <bool>                        latest or not
:local checkVersion do={
    #DEFINE global
    :global IsNothing;
    :global TypeofBool;
    :global ReadOption;
    :global GetFunc;
    :global GetConfig;
    :global UpdateConfig;
    :global GlobalEnvInfo;
    :global GetCurrentDatetime;
    :global GetTimedelta;
    # env
    :global EnvRSPMVersion;
    :global EnvRSPMBaseURL;
    # check
    :if ([$IsNothing $GlobalEnvInfo]) do={
        :error "rspm.state.checkVersion: \$GlobalEnvInfo is nothing!";
    }
    :if ([$IsNothing $EnvRSPMVersion]) do={
        :error "rspm.state.checkVersion: \$EnvRSPMVersion is nothing!";
    }
    # local
    :local forceUpdate [$ReadOption $ForceUpdate $TypeofBool false];
    :local configPkgName "config.rspm.package";
    :local td 00:30:00;
    # check DT
    :if (!$forceUpdate) do={
        :local sdt ((($GlobalEnvInfo->"data")->"EnvRSPMVersion")->"updateDT");
        :local cdt [$GetCurrentDatetime];
        :local ctd [$GetTimedelta $sdt $cdt];
        # return true if in expire time
        :if ($ctd < $td) do={:return true};
    }
    # do update
    :local versionURL ($EnvRSPMBaseURL . "res/version.rsc");
    :local versionR [[$GetFunc "tool.remote.loadRemoteVar"] URL=$versionURL];
    :local config [$GetConfig $configPkgName];
    :set (($config->"environment")->"RSPMVersion") $versionR;
    :local versionL $EnvRSPMVersion;
    [$UpdateConfig $configPkgName $config];
    :return ($versionL >= $versionR);
}


# $checkState
# Compare package in local repository and configuration file.
# | ----------------------- | ----------------------- | -----------------------
# |     meta from script    |     meta from config    |    state & advice
# | ----------------------- | ----------------------- | -----------------------
# |       read error        |          exist          |   ERR, remove script file manually
# |         exist           |        read error       |   ERR, config corrupted
# |       not exist         |        not exist        |   ERR, update config
# | ----------------------- | ----------------------- | -----------------------
# |     meta from script    |     meta from config    |    state & action
# | ----------------------- | ----------------------- | -----------------------
# |  exist(higher version)  |          exist          |   LT,   remove;reinstall;downgrade
# |   exist(same version)   |          exist          |   SAME, remove;reinstall;downgrade
# |         exist           |  exist(higher version)  |   GT,   remove;upgrade;downgrade
# |       not exist         |          exist          |   NES,  install
# |         exist           |        not exist        |   NEC,  register
# | ----------------------- | ----------------------- | -----------------------
# return example:
# {
#     "state"=<state code>;
#     "advice"={"desc1";"desc2"};
#     "action"={"install";"upgrade";"remove";"register"};
#     "metaScript"={} or nil;
#     "metaConfig"={} or nil;
#     "configName"="config.rspm.package" or "";
# }
# error return example:
# {
#     "state"="ERR";
#     "advice"="";
# }
# kwargs: Package=<str>             package name
# opt kwargs: Suppress=<bool>       suppress error
# return: <array->str>(<report>)
:local checkState do={
    #DEFINE global
    :global Nil;
    :global IsNil;
    :global IsStr;
    :global IsEmpty;
    :global IsNum;
    :global IsNothing;
    :global NewArray;
    :global FindPackage;
    :global GetConfig;
    :global GetMetaSafe;
    :global ReadOption;
    :global TypeofBool;
    # check
    :if (![$IsStr $Package]) do={
        :error "rspm.state.checkState: \$Package should be str.";
    }
    :if ($Package = "") do={
        :error "rspm.state.checkState: \$Package is empty.";
    }
    # local
    :local configPkgName "config.rspm.package";
    :local configExtPkgName "config.rspm.package.ext";
    :local metaConfig;
    :local metaScript;
    :local configName;
    :local state;
    :local actionList [$NewArray ];
    :local adviceList [$NewArray ];
    :local flagSuppress [$ReadOption $Suppress $TypeofBool false];
    # read config
    :local config;
    :local configExt;
    # suppress read config error
    :local flagReadConfig true;
    :do {
        :set config [$GetConfig $configPkgName];
        :set configExt [$GetConfig $configExtPkgName];
    } on-error={
        :set flagReadConfig false;
    };
    :if (!$flagReadConfig) do={
        :if ($flagSuppress) do={
            :local err {
                "state"="ERR";
                "advice"={
                    "Read local package list error, configuration may corrupted.";
                    "Using \"rspm.reset.resetConfig\" to reset local configuration.";
                };
            }
            :return $err;
        } else {
            :error "rspm.state.checkState: error occurred when read package list.";
        }
    }
    # find in config
    :local pkgNum (($config->"packageMapping")->$Package);
    :if ([$IsNum $pkgNum]) do={
        :set configName $configPkgName;
        :set metaConfig (($config->"packageList")->$pkgNum);
    } else {
        :local pkgExtNum (($configExt->"packageMapping")->$Package);
        :if ([$IsNum $pkgExtNum]) do={
            :set configName $configExtPkgName;
            :set metaConfig (($configExt->"packageList")->$pkgExtNum);
        } else {
            :set configName "";
            :set metaConfig $Nil;
        }
    }
    # find in repo
    :local pkgIDList [$FindPackage $Package];
    :if ([$IsEmpty $pkgIDList]) do={
        :set metaScript $Nil;
    } else {
        :local va {"type"="code"};
        :if ($configName = $configExtPkgName) do={
            :set ($va->"url") true;
        };
        # suppress error when reading script meta
        :local flagReadScript true;
        :do {
            :set metaScript [$GetMetaSafe $Package VA=$va];
        } on-error={
            :set flagReadScript false;
        };
        :if (!$flagReadScript) do={
            :local ad {
                "The package $Package has found in local repository but can't get meta from it.";
                "It occurrs if your local script contains illegal meta info, or is corrupted.";
                "Using \"/system/script/remove [\$FindPackage $Package]\" to manually delete it.";
            }
            :if ($flagSuppress) do={
                :local err {
                    "state"="ERR";
                    "advice"=$ad;
                };
                :return $err;
            } else {
                :foreach v in $ad do={
                    :put $v;
                }
                :error "rspm.state.checkState: error occurred when read script meta.";
            };
        }
    }
    # make action list
    :if ([$IsNil $metaConfig] and [$IsNil $metaScript]) do={
        :local ad {
            "The package $Package is not found in the repository and the package list.";
            "Using [[\$GetFunc \"rspm.update\"]] to get latest package list.";
        };
        :if ($flagSuppress) do={
            :local err {
                "state"="ERR";
                "advice"=$ad;
            };
            :return $err;
        } else {
            :foreach v in $ad do={
                :put $v;
            }
            :error "rspm.state.checkState: package $Package not found";
        }
    }
    # state
    :local flag true;
    :if ($flag and [$IsNil $metaConfig]) do={
        :set flag false;
        :set state "NEC";
        :set ($actionList->[:len $actionList]) "register";
        :set ($adviceList->[:len $adviceList]) "The package $Package is only found in local repository.";
        :set ($adviceList->[:len $adviceList]) "Using \"rspm.register\" to register this package into package list.";
    }
    :if ($flag and [$IsNil $metaScript]) do={
        :set flag false;
        :set state "NES";
        :set ($actionList->[:len $actionList]) "install";
        :set ($adviceList->[:len $adviceList]) "The package $Package is only found in local package list.";
        :set ($adviceList->[:len $adviceList]) "Using \"rspm.install\" to install this package.";
    }
    :if ($flag) do={
        :local versionConfig ($metaConfig->"version");
        :local versionScript ($metaScript->"version");
        # TODO: better version compare
        :if ($versionConfig < $versionScript) do={
            :set state "LT";
            :set ($actionList->[:len $actionList]) "remove";
            :set ($actionList->[:len $actionList]) "reinstall";
            :set ($actionList->[:len $actionList]) "downgrade";
            :set ($adviceList->[:len $adviceList]) "The package $Package can be reinstall(version: $versionScript, latest: $versionConfig).";
            :set ($adviceList->[:len $adviceList]) "Using \"rspm.remove\" to remove this package.";
            :set ($adviceList->[:len $adviceList]) "Using \"rspm.install\" to reinstall this package.";
            :set ($adviceList->[:len $adviceList]) "Using \"rspm.downgrade\" to downgrade this package.";
        }
        :if ($versionConfig = $versionScript) do={
            :set state "SAME";
            :set ($actionList->[:len $actionList]) "remove";
            :set ($actionList->[:len $actionList]) "reinstall";
            :set ($actionList->[:len $actionList]) "downgrade";
            :set ($adviceList->[:len $adviceList]) "The package $Package is up to date(version: $versionConfig).";
            :set ($adviceList->[:len $adviceList]) "Using \"rspm.remove\" to remove this package.";
            :set ($adviceList->[:len $adviceList]) "Using \"rspm.install\" to reinstall this package.";
            :set ($adviceList->[:len $adviceList]) "Using \"rspm.downgrade\" to downgrade this package.";
        }
        :if ($versionConfig > $versionScript) do={
            :set state "GT";
            :set ($actionList->[:len $actionList]) "remove";
            :set ($actionList->[:len $actionList]) "upgrade";
            :set ($actionList->[:len $actionList]) "downgrade";
            :set ($adviceList->[:len $adviceList]) "The package $Package can be upgraded(version: $versionScript, latest: $versionConfig).";
            :set ($adviceList->[:len $adviceList]) "Using \"rspm.remove\" to remove this package.";
            :set ($adviceList->[:len $adviceList]) "Using \"rspm.upgrade\" to upgrade this package.";
            :set ($adviceList->[:len $adviceList]) "Using \"rspm.downgrade\" to downgrade this package.";
        }
    }
    # make result
    :local result {
        "package"=$Package;
        "metaScript"=$metaScript;
        "metaConfig"=$metaConfig;
        "configName"=$configName;
        "state"=$state;
        "actions"=$actionList;
        "advice"=$adviceList;
    }
    :return $result;
}


# $checkAllState
# opt kwargs: CheckExt=<bool>           default true, check custom packages or not
# opt kwargs: CheckVersion=<bool>       default true, check version online
# return: <array->report>
:local checkAllState do={
    #DEFINE global
    :global NewArray;
    :global FindPackage;
    :global GetConfig;
    :global GetFunc;
    :global ReadOption;
    :global TypeofBool;
    # local
    :local pCheckExt [$ReadOption $CheckExt $TypeofBool true];
    :local pCheckVersion [$ReadOption $CheckVersion $TypeofBool true];
    :local reportList [$NewArray ];
    :local configPkgName "config.rspm.package";
    :local configExtPkgName "config.rspm.package.ext";
    :local config [$GetConfig $configPkgName];
    :local configExt [$GetConfig $configExtPkgName];
    # check version
    :local flagVersion [[$GetFunc "rspm.state.checkVersion"]];
    :if ($pCheckVersion and !$flagVersion) do={
        :error "rspm.state.checkAllState: local package list is out of date, please update first.";
    }
    # core
    :foreach meta in ($config->"packageList") do={
        :local pkgName ($meta->"name");
        :local report [[$GetFunc "rspm.state.checkState"] Package=$pkgName Suppress=true];
        :set ($reportList->[:len $reportList]) $report;
    }
    # ext
    :foreach meta in ($configExt->"packageList") do={
        :local pkgName ($meta->"name");
        :local report [[$GetFunc "rspm.state.checkState"] Package=$pkgName Suppress=true];
        :set ($reportList->[:len $reportList]) $report;
    }
    :return $reportList;
}


:local package {
    "metaInfo"=$metaInfo;
    "checkVersion"=$checkVersion;
    "checkState"=$checkState;
    "checkAllState"=$checkAllState;
}
:return $package;