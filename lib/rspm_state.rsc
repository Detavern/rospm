:local metaInfo {
    "name"="rspm.state";
    "version"="0.0.1";
    "description"="rspm package state tools";
};


# $checkVersion
# check if the package list version is the latest.
# opt kwargs: ForceUpdate=<bool>        false(default), force reload remote version
# return: <bool>                        latest or not
:local checkVersion do={
    #DEFINE global
    :global IsNil;
    :global GetConfig;
    :global GetFunc;
    :global ReadOption;
    :global TypeofBool;
    :global SetGlobalVar;
    :global LoadGlobalVar;
    # local
    :local forceUpdate [$ReadOption $ForceUpdate $TypeofBool false];
    :local configPkgName "config.rspm.package";
    :local config [$GetConfig $configPkgName];
    :local versionL ($config->"version");
    # remote version
    :local versionRName "RSPMRemoteVersion";
    :local versionR [$LoadGlobalVar $versionRName];
    :if ([$IsNil $versionR] or $forceUpdate) do={
        :local versionURL (($config->"baseURL") . "res/version.rsc");
        :set versionR [[$GetFunc "tool.remote.loadRemoteVar"] URL=$versionURL];
        [$SetGlobalVar $versionRName $versionR Timeout=00:30:00];
    };
    :return ($versionL >= $versionR);
}


# $checkState
# compare package in local repository and configuration file.
# | ----------------------- | ----------------------- | -----------------------
# |     meta from script    |     meta from config    |    state & advice
# | ----------------------- | ----------------------- | -----------------------
# |       read error        |          exist          |   ERR, remove script file manually
# |         exist           |        read error       |   ERR, config corrupted
# |       not exist         |        not exist        |   ERR, update config
# | ----------------------- | ----------------------- | -----------------------
# |     meta from script    |     meta from config    |    state & action
# | ----------------------- | ----------------------- | -----------------------
# |  exist(higher version)  |          exist          |   LT,   remove;install(downgrade)
# |   exist(same version)   |          exist          |   SAME, remove;register(do nothing);install(reinstall)
# |         exist           |  exist(higher version)  |   GT,   remove;upgrade
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
    :global GetMeta;
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
    } on-error {
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
            :set metaScript [$GetMeta $Package VA=$va];
        } on-error {
            :set flagReadScript false;
        };
        :if (!$flagReadScript) do={
            :local ad {
                "The package $Package has found in local repository but can't get meta from it.";
                "It occurred when your local script is not a valid package, or corrupted.";
                "Using \"/system script remove [$FindPackage $Package]\" to manually delete it.";
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
        :if ($versionConfig = $versionScript) do={
            :set state "SAME";
            :set ($actionList->[:len $actionList]) "remove";
            :set ($actionList->[:len $actionList]) "install";
            :set ($actionList->[:len $actionList]) "register";
            :set ($adviceList->[:len $adviceList]) "The package $Package is up to date(version: $versionConfig).";
            :set ($adviceList->[:len $adviceList]) "Using \"rspm.remove\" to remove this package.";
            :set ($adviceList->[:len $adviceList]) "Using \"rspm.install\" to reinstall this package.";
        }
        :if ($versionConfig > $versionScript) do={
            :set state "GT";
            :set ($actionList->[:len $actionList]) "remove";
            :set ($actionList->[:len $actionList]) "upgrade";
            :set ($adviceList->[:len $adviceList]) "The package $Package can be upgraded(version: $versionScript, latest: $versionConfig).";
            :set ($adviceList->[:len $adviceList]) "Using \"rspm.remove\" to remove this package.";
            :set ($adviceList->[:len $adviceList]) "Using \"rspm.upgrade\" to upgrade this package.";
        }
        :if ($versionConfig < $versionScript) do={
            :set state "LT";
            :set ($actionList->[:len $actionList]) "remove";
            :set ($actionList->[:len $actionList]) "install";
            :set ($adviceList->[:len $adviceList]) "The package $Package can be downgraded(version: $versionScript, latest: $versionConfig).";
            :set ($adviceList->[:len $adviceList]) "Using \"rspm.remove\" to remove this package.";
            :set ($adviceList->[:len $adviceList]) "Using \"rspm.install\" to downgrade this package.";
        }
    }
    # make result
    :local result {
        "metaScript"=$metaScript;
        "metaConfig"=$metaConfig;
        "configName"=$configName;
        "state"=$state;
        "action"=$actionList;
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
}


:local package {
    "metaInfo"=$metaInfo;
    "checkVersion"=$checkVersion;
    "checkState"=$checkState;
    "checkAllState"=$checkAllState;
}
:return $package;
