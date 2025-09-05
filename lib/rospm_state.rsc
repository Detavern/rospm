#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   rospm.state
# ===================================================================
# ALL package level functions follows lower camel case.
# This package provides tools for checking and managing the state of ROSPM packages.
#
# Copyright (c) 2020-2025 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="rospm.state";
	"version"="0.7.0";
	"description"="This package provides tools for checking and managing the state of ROSPM packages.";
	"essential"=true;
	"global"=false;
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
	:global GetTimeDiff;
	:global CompareVersion;
	# env
	:global EnvROSPMVersion;
	:global EnvROSPMBaseURL;
	# check
	:if ([$IsNothing $GlobalEnvInfo]) do={
		:error "rospm.state.checkVersion: \$GlobalEnvInfo is nothing!";
	}
	:if ([$IsNothing $EnvROSPMVersion]) do={
		:error "rospm.state.checkVersion: \$EnvROSPMVersion is nothing!";
	}
	# local
	:local forceUpdate [$ReadOption $ForceUpdate $TypeofBool false];
	:local configPkgName "config.rospm.package";
	:local td 00:30:00;
	# check DT
	:if (!$forceUpdate) do={
		:local sdt ((($GlobalEnvInfo->"data")->"EnvROSPMVersion")->"updateDT");
		:local cdt [$GetCurrentDatetime];
		:local ctd [$GetTimeDiff $sdt $cdt];
		# return true if in expire time
		:if ($ctd < $td) do={:return true};
	}
	# do update
	:local versionURL ($EnvROSPMBaseURL . "res/version.rsc");
	:local versionR [[$GetFunc "tool.remote.loadRemoteVar"] URL=$versionURL];
	:local config [$GetConfig $configPkgName];
	:set (($config->"environment")->"ROSPMVersion") $versionR;
	:local versionL $EnvROSPMVersion;
	[$UpdateConfig $configPkgName $config];
	:return ([$CompareVersion $versionL $versionR] >= 0);
}


# $checkState
# Compare package in local repository and configuration file.
# | ----------------------- | ----------------------- | -----------------------
# |     meta from script    |     meta from config    |    state & advice
# | ----------------------- | ----------------------- | -----------------------
# |        read error       |          exist          |   ERR, remove script file manually
# |          exist          |        read error       |   ERR, config corrupted
# |        not exist        |        not exist        |   ERR, update config
# | ----------------------- | ----------------------- | -----------------------
# |     meta from script    |     meta from config    |    state & action
# | ----------------------- | ----------------------- | -----------------------
# |  exist(higher version)  |          exist          |   LT,   remove;reinstall;downgrade
# |  exist(same version)    |          exist          |   SAME, remove;reinstall;downgrade
# |  exist(lower version)   |          exist          |   GT,   remove;upgrade;downgrade
# |          exist          |    exist(local flag)    |   LOC,  remove
# |        not exist        |          exist          |   NES,  install
# |          exist          |        not exist        |   NEC,  register
# | ----------------------- | ----------------------- | -----------------------
# return example:
# {
#     "state"=<state code>;
#     "advice"={"desc1";"desc2"};
#     "action"={"install";"upgrade";"remove";"register"};
#     "metaScript"={} or nil;
#     "metaConfig"={} or nil;
#     "configName"="config.rospm.package" or "";
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
	:global CompareVersion;
	# check
	:if (![$IsStr $Package]) do={
		:error "rospm.state.checkState: \$Package should be str.";
	}
	:if ($Package = "") do={
		:error "rospm.state.checkState: \$Package is empty.";
	}
	# local
	:local configPkgName "config.rospm.package";
	:local configExtPkgName "config.rospm.package.ext";
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
					"Using \"rospm.reset.resetConfig\" to reset local configuration.";
				};
			}
			:return $err;
		} else {
			:error "rospm.state.checkState: error occurred when read package list.";
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
			:set ($va->"extl") true;
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
				"The package $Package has found in local repository but could not validate its meta.";
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
				:error "rospm.state.checkState: error occurred when read script meta.";
			};
		}
	}
	# make action list
	:if ([$IsNil $metaConfig] and [$IsNil $metaScript]) do={
		:local ad {
			"The package $Package is not found in the repository and the package list.";
			"Using [[\$GetFunc \"rospm.update\"]] to get latest package list.";
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
			:error "rospm.state.checkState: package $Package not found";
		}
	}
	# state
	:local flag true;
	:if ($flag and [$IsNil $metaConfig]) do={
		:set flag false;
		:set state "NEC";
		:set ($actionList->[:len $actionList]) "register";
		:set ($adviceList->[:len $adviceList]) "The package $Package is only found in local repository.";
		:set ($adviceList->[:len $adviceList]) "Using \"rospm.register\" to register this package into package list.";
	}
	:if ($flag and [$IsNil $metaScript]) do={
		:set flag false;
		:set state "NES";
		:set ($actionList->[:len $actionList]) "install";
		:set ($adviceList->[:len $adviceList]) "The package $Package is only found in local package list.";
		:set ($adviceList->[:len $adviceList]) "Using \"rospm.install\" to install this package.";
	}
	:if ($flag) do={
		:local versionConfig ($metaConfig->"version");
		:local versionScript ($metaScript->"version");
		:local flagLocal [$ReadOption ($metaConfig->"local") $TypeofBool false];
		# local
		:if ($flagLocal) do={
			:set state "LOC";
			:set ($actionList->[:len $actionList]) "remove";
			:set ($adviceList->[:len $adviceList]) "Local package $Package can only be removed(version: $versionScript).";
			:set ($adviceList->[:len $adviceList]) "Using \"rospm.remove\" to remove this package.";
		}
		# version compare
		:if (!$flagLocal and ([$CompareVersion $versionConfig $versionScript] < 0)) do={
			:set state "LT";
			:set ($actionList->[:len $actionList]) "remove";
			:set ($actionList->[:len $actionList]) "reinstall";
			:set ($actionList->[:len $actionList]) "downgrade";
			:set ($adviceList->[:len $adviceList]) "The package $Package can be reinstalled(version: $versionScript, latest: $versionConfig).";
			:set ($adviceList->[:len $adviceList]) "Using \"rospm.remove\" to remove this package.";
			:set ($adviceList->[:len $adviceList]) "Using \"rospm.install\" to reinstall this package.";
			:set ($adviceList->[:len $adviceList]) "Using \"rospm.downgrade\" to downgrade this package.";
		}
		:if (!$flagLocal and ([$CompareVersion $versionConfig $versionScript] = 0)) do={
			:set state "SAME";
			:set ($actionList->[:len $actionList]) "remove";
			:set ($actionList->[:len $actionList]) "reinstall";
			:set ($actionList->[:len $actionList]) "downgrade";
			:set ($adviceList->[:len $adviceList]) "The package $Package is up to date(version: $versionConfig).";
			:set ($adviceList->[:len $adviceList]) "Using \"rospm.remove\" to remove this package.";
			:set ($adviceList->[:len $adviceList]) "Using \"rospm.install\" to reinstall this package.";
			:set ($adviceList->[:len $adviceList]) "Using \"rospm.downgrade\" to downgrade this package.";
		}
		:if (!$flagLocal and ([$CompareVersion $versionConfig $versionScript] > 0)) do={
			:set state "GT";
			:set ($actionList->[:len $actionList]) "remove";
			:set ($actionList->[:len $actionList]) "upgrade";
			:set ($actionList->[:len $actionList]) "downgrade";
			:set ($adviceList->[:len $adviceList]) "The package $Package can be upgraded(version: $versionScript, latest: $versionConfig).";
			:set ($adviceList->[:len $adviceList]) "Using \"rospm.remove\" to remove this package.";
			:set ($adviceList->[:len $adviceList]) "Using \"rospm.upgrade\" to upgrade this package.";
			:set ($adviceList->[:len $adviceList]) "Using \"rospm.downgrade\" to downgrade this package.";
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
	:local configPkgName "config.rospm.package";
	:local configExtPkgName "config.rospm.package.ext";
	:local config [$GetConfig $configPkgName];
	:local configExt [$GetConfig $configExtPkgName];
	# check version
	:local flagVersion [[$GetFunc "rospm.state.checkVersion"]];
	:if ($pCheckVersion and !$flagVersion) do={
		:error "rospm.state.checkAllState: local package list is out of date, please update first.";
	}
	# core
	:foreach meta in ($config->"packageList") do={
		:local pkgName ($meta->"name");
		:local report [[$GetFunc "rospm.state.checkState"] Package=$pkgName Suppress=true];
		:set ($reportList->[:len $reportList]) $report;
	}
	# ext
	:foreach meta in ($configExt->"packageList") do={
		:local pkgName ($meta->"name");
		:local report [[$GetFunc "rospm.state.checkState"] Package=$pkgName Suppress=true];
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
