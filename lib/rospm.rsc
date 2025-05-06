#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   rospm
# ===================================================================
# ALL package level functions follows lower camel case.
# ROSPM package entrypoints
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="rospm";
	"version"="0.5.2";
	"description"="ROSPM package entrypoints";
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
	# check
	:local context [$ReadOption $Context $TypeofArray];
	# init config
	[[$GetFunc "rospm.config.generateConfig"]];
	:set context [[$GetFunc "rospm.config.generatePackageConfig"] Context=$context];
	[[$GetFunc "rospm.config.generatePackageExtConfig"]];
	# local
	:local baseURL ($context->"ROSPMBaseURL");
	# check current installation
	# compare current with packagelist, and make install/upgrade advice
	:local reportList [[$GetFunc "rospm.state.checkAllState"] CheckExt=false CheckVersion=false];
	:foreach report in $reportList do={
		:local state ($report->"state");
		# remote version lt local, warn it and let user determine
		:if ($state = "LT") do={
			:put "Local version is higher than the remote. This might be due to some local modifications.";
			:local answer [$InputV ("Enter yes to reinstall.") Default=no];
			:if ($answer) do={
				[[$GetFunc "rospm.action.reinstall"] Report=$report];
			}
		};
		# remote version gt local, let user know it will be updated
		:if ($state = "GT") do={
			[[$GetFunc "rospm.action.upgrade"] Report=$report];
		};
		# not exist in local repository, use config to install it
		:if ($state = "NES") do={
			:local pn (($report->"metaConfig")->"name");
			:local epkgList ($packageInfo->"essentialPackageList");
			:if ([$InValues $pn $epkgList]) do={
				[[$GetFunc "rospm.action.install"] Report=$report];
			}
		};
	}
	# register startup
	:local startupName "ROSPM_STARTUP";
	:local startupResURL ($baseURL . "res/startup.rsc");
	:put "Get: $startupResURL";
	:local scriptStr [[$GetFunc "tool.remote.loadRemoteSource"] URL=$startupResURL Normalize=true];
	/system/scheduler/remove [/system/scheduler/find name=$startupName];
	:put "Adding $startupName schedule...";
	# add scheduler use default policy
	:local scheduleComment "managed by ROSPM";
	/system/scheduler/add name=$startupName comment=$scheduleComment \
		start-time=startup on-event=$scriptStr;
	:return $Nil;
}


# $printUpgradePrompts
# kwargs: Num=<num>             upgrade count
# opt kwargs: IsExt=<bool>      is extension package
:local printUpgradePrompts do={
	#DEFINE global
	:global Nil;
	:global ReadOption;
	:global TypeofNum;
	:global TypeofBool;
	# read opt
	:local pNum [$ReadOption $Num $TypeofNum];
	:local pIsExt [$ReadOption $IsExt $TypeofBool false];
	# local
	:local pkgType "core";
	:if ($pIsExt) do={:set pkgType "extension"};
	:if ($pNum = 0) do={
		:put "All $pkgType packages are up to date.";
		:return $Nil;
	}
	:if ($pNum = 1) do={
		:put "1 $pkgType package needs upgrade.";
		:return $Nil;
	}
	:put "$pNum $pkgType packages need upgrade.";
}


# $update
# Update local package configuration file.
# kwargs: Package=<str>         package name
:local update do={
	#DEFINE global
	:global Nil;
	:global NewArray;
	:global GetFunc;
	:global GetConfig;
	:global UpdateConfig;
	:global ReadOption;
	:global TypeofStr;
	:global TypeofBool;
	:global InKeys;
	:global ValidateMetaInfo;
	# env
	:global EnvROSPMBaseURL;
	:global EnvROSPMVersion;
	# local
	:local configPkgName "config.rospm.package";
	:local configExtPkgName "config.rospm.package.ext";
	:put "Loading local core package list...";
	:local config [$GetConfig $configPkgName];
	:put "Loading local extension package list...";
	:local configExt [$GetConfig $configExtPkgName];
	:local version $EnvROSPMVersion;
	:local newConfigExt;
	# add resource version
	:local resVersionURL ($EnvROSPMBaseURL . "res/version.rsc");
	:put "Get: $resVersionURL";
	:local resVersion [[$GetFunc "tool.remote.loadRemoteVar"] URL=$resVersionURL];
	# check core
	:put "Checking core packages...";
	:if ($version >= $resVersion) do={
		:put "Core package list is up-to-date.";
		:set newConfigExt $configExt;
	} else {
		:put "Latest version is $resVersion, your current version is $version";
		# update package-info
		:local packageInfoURL ($EnvROSPMBaseURL . "res/package-info.rsc");
		:put "Get: $packageInfoURL";
		:local packageInfo [[$GetFunc "tool.remote.loadRemoteVar"] URL=$packageInfoURL];
		:put "Updating core package list...";
		:foreach k,v in $packageInfo do={
			:set ($config->$k) $v;
		}
		:set (($config->"environment")->"ROSPMVersion") $resVersion;
		[$UpdateConfig $configPkgName $config];
		# update package-info-ext
		:local packageInfoExtURL ($EnvROSPMBaseURL . "res/package-info-ext.rsc");
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
		:local startupName "ROSPM_STARTUP";
		:local startupResURL ($EnvROSPMBaseURL . "res/startup.rsc");
		:put "Get: $startupResURL";
		:local scriptStr [[$GetFunc "tool.remote.loadRemoteSource"] URL=$startupResURL Normalize=true];
		/system/scheduler/remove [/system/scheduler/find name=$startupName];
		:put "Updating startup scheduler...";
		# add scheduler use default policy
		:local scheduleComment "managed by ROSPM";
		/system/scheduler/add name=$startupName comment=$scheduleComment \
			start-time=startup on-event=$scriptStr;
	}
	# get upgrade count
	:local counter 0;
	:local reportList [[$GetFunc "rospm.state.checkAllState"]];
	:foreach report in $reportList do={
		:if (($report->"state") = "GT") do={
			:set counter ($counter+1);
		}
	};
	# check ext
	:local counterExt 0;
	:put "Checking extension packages...";
	:foreach meta in ($newConfigExt->"packageList") do={
		:local extName ($meta->"name");
		:local extVerL ($meta->"version");
		:local flagL [$ReadOption ($meta->"local") $TypeofBool false];
		:if ($flagL) do={
			:put "Package $extName:$extVerL is a local package, skipped.";
		} else {
			:local pkgURL [$ReadOption ($meta->"proxyUrl") $TypeofStr ($meta->"url")];
			# load remote package check version
			:put "Get: $pkgURL";
			:local pkgExt [[$GetFunc "tool.remote.loadRemoteVar"] URL=$pkgURL];
			# check pkg
			:local va {"type"="code";"name"=($meta->"name");"ext"=true};
			:local vres [$ValidateMetaInfo ($pkgExt->"metaInfo") $va];
			if (!($vres->"flag")) do={
				:put "Error occured when loading remote resource of \"$extName\":";
				:foreach reason in ($vres->"reasons") do={
					:put "  $reason";
				}
			} else {
				:local extVerR (($pkgExt->"metaInfo")->"version");
				:if ($extVerL < $extVerR) do={
					:set counterExt ($counterExt+1);
					:foreach k,v in ($pkgExt->"metaInfo") do={
						:set ($meta->$k) $v;
					}
				}
			}
		}
	}
	# update ext config
	:put "Updating extension package list...";
	[$UpdateConfig $configExtPkgName $newConfigExt];
	# count core packages
	[[$GetFunc "rospm.printUpgradePrompts"] Num=$counter];
	# count extension packages
	[[$GetFunc "rospm.printUpgradePrompts"] Num=$counterExt IsExt=true];
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
	:local report [[$GetFunc "rospm.state.checkState"] Package=$pkgName];
	:local state ($report->"state");
	# do nothing if LOC
	:if ($state = "LOC") do={
		:return $Nil;
	}
	# register
	:if ($state = "NEC") do={
		[[$GetFunc "rospm.action.register"] Report=$report];
		:return $Nil;
	}
	# fallback
	:foreach ad in ($report->"advice") do={
		:put $ad;
	}
	:error "rospm.register: state not match.";
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
	:local isLatest [[$GetFunc "rospm.state.checkVersion"] ];
	:if (!$isLatest) do={
		:error "rospm.install: local package list is out of date, please update first.";
	}
	# install ext package by url
	:if ($pURL != "") do={
		[[$GetFunc "rospm.action.installExt"] URL=$pURL];
	}
	# generate report
	:put "Check package $pkgName state...";
	:local report [[$GetFunc "rospm.state.checkState"] Package=$pkgName];
	:local state ($report->"state");
	# install
	:if ($state = "NES") do={
		[[$GetFunc "rospm.action.install"] Report=$report];
		:return $Nil;
	}
	# suggest reinstalling the package
	:if ($state = "LT") do={
		:if ($pSuggestion) do={
			:put "Local version is higher than the remote. This might be due to some local modifications.";
			:local answer [$InputV ("Enter yes to reinstall.") Default=yes];
			:if ($answer) do={
				[[$GetFunc "rospm.action.reinstall"] Report=$report];
				:return $Nil;
			}
		}
		:put "Package $pkgName may be modified, could be reinstall, skipped...";
		:return $Nil;
	}
	# suggest reinstalling the package
	:if ($state = "SAME") do={
		:if ($pSuggestion) do={
			:put "Local version is equal to the remote.";
			:local answer [$InputV ("Enter yes to reinstall.") Default=no];
			:if ($answer) do={
				[[$GetFunc "rospm.action.reinstall"] Report=$report];
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
	:error "rospm.install: state not match.";
}


# $remove
# kwargs: Package=<str>         package name
:local remove do={
	#DEFINE global
	:global Nil;
	:global GetFunc;
	:global GetConfig;
	# local
	:local configPkgName "config.rospm.package";
	:put "Loading local core package list...";
	:local config [$GetConfig $configPkgName];
	# opt
	:local pkgName $Package;
	# generate report
	:put "Check package $pkgName state...";
	:local report [[$GetFunc "rospm.state.checkState"] Package=$pkgName];
	:local state ($report->"state");
	# comment if not installed
	:if ($state = "NES") do={
		:put "Package $pkgName has not yet installed.";
		:error "rospm.remove: state not match.";
	}
	# comment to register it first
	:if ($state = "NEC") do={
		:put "Package $pkgName found, but it is an orphaned one. You should register it first.";
		:error "rospm.remove: state not match.";
	}
	# remove
	[[$GetFunc "rospm.action.remove"] Report=$report];
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
	:local report [[$GetFunc "rospm.state.checkState"] Package=$pkgName];
	:local state ($report->"state");
	# upgrade
	:if ($state = "GT") do={
		[[$GetFunc "rospm.action.upgrade"] Report=$report];
		:return $Nil;
	}
	# fallback
	:foreach ad in ($report->"advice") do={
		:put $ad;
	}
	:error "rospm.upgrade: state not match.";
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
	:global EnvROSPMBaseURL;
	:global EnvROSPMOwner;
	# local
	:local configPkgName "config.rospm.package";
	:local configExtPkgName "config.rospm.package.ext";
	:put "Loading local core package list...";
	:local config [$GetConfig $configPkgName];
	:put "Loading local extension package list...";
	:local configExt [$GetConfig $configExtPkgName];
	# check latest
	:local isLatest [[$GetFunc "rospm.state.checkVersion"] ];
	:if (!$isLatest) do={
		# TODO: interactive to update
		:error "rospm.upgradeAll: local package list is out of date, please update first.";
	}
	# generate upgrade list
	:local reportList [[$GetFunc "rospm.state.checkAllState"] ];
	:local upgradeList [$NewArray ];
	:foreach report in $reportList do={
		:if (($report->"state") = "GT") do={
			:set ($upgradeList->[:len $upgradeList]) $report;
		}
	};
	# do upgrade
	:local lenUpradeList [:len $upgradeList];
	# TODO: improve prompt
	:put "$lenUpradeList packages need upgrade.";
	:foreach report in $upgradeList do={
		[[$GetFunc "rospm.action.upgrade"] Report=$report];
	};
	:put "$lenUpradeList packages have been upgraded.";
	:return $Nil;
}


:local package {
	"metaInfo"=$metaInfo;
	"firstRun"=$firstRun;
	"printUpgradePrompts"=$printUpgradePrompts;
	"update"=$update;
	"register"=$register;
	"install"=$install;
	"remove"=$remove;
	"upgrade"=$upgrade;
	"upgradeAll"=$upgradeAll;
}
:return $package;
