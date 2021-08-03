:local metaInfo {
    "name"="rspm.state";
    "version"="0.0.1";
    "description"="rspm package state tools";
};


# $checkVersion
# check if the package list version is the latest.
# return: <bool>            latest or not
:local checkVersion do={
    #DEFINE global
    :global GetConfig;
    :global GetFunc;
    # local
    :local configPkgName "config.rspm.package";
    :local config [$GetConfig $configPkgName];
    :local versionL ($config->"version");
    # remote version
    :local versionURL (($config->"baseURL") . "res/version.rsc");
    :local versionR [[$GetFunc "tool.remote.loadRemoteVar"] URL=$versionURL];
    :return ($versionL >= $versionR)
}


# $checkState
# compare package in local repository and configuration file.
# | ----------------------- | ----------------------- | -----------------------
# |     meta from script    |     meta from config    |    state & action
# | ----------------------- | ----------------------- | -----------------------
# |       read error        |          exist          |   error, remove script file manually
# |         exist           |        read error       |   error, config corrupted
# |       not exist         |        not exist        |   error, update config
# | ----------------------- | ----------------------- | -----------------------
# |  exist(higher version)  |          exist          |   LT,   remove;install(downgrade)
# |   exist(same version)   |          exist          |   SAME, remove
# |         exist           |  exist(higher version)  |   GT,   remove;upgrade
# |       not exist         |          exist          |   NES,  install
# |         exist           |        not exist        |   NEC,  register
# | ----------------------- | ----------------------- | -----------------------
# return example:
# {
#     "metaScript"={} or nil;
#     "metaConfig"={} or nil;
#     "configName"="config.rspm.package" or "";
#     "action"={"install";"upgrade";"remove";"register"};
#     "state"=<state code>;
#     "advice"={"desc1";"desc2"};
# }
# kwargs: Package=<str>         package name
# return: <array->str>
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
    # read config
    :local config [$GetConfig $configPkgName];
    :local configExt [$GetConfig $configExtPkgName];
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
        }
        :set metaScript [$GetMeta $Package VA=$va];
    }
    # make action list
    :if ([$IsNil $metaConfig] and [$IsNil $metaScript]) do={
        :put "The package $Package is not found in the repository and the package list.";
        :put "Using [[\$GetFunc \"rspm.update\"]] to get latest package list.";
        :error "rspm.state.checkState: package $Package not found";
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
            :set ($adviceList->[:len $adviceList]) "The package $Package is up to date(version: $versionConfig).";
            :set ($adviceList->[:len $adviceList]) "Using \"rspm.remove\" to remove this package.";
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


:local package {
    "metaInfo"=$metaInfo;
    "checkVersion"=$checkVersion;
    "checkState"=$checkState;
}
:return $package;
