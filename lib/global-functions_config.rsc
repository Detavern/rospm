#!rsc by RouterOS
# ===================================================================
# |     Global Functions     |   global-functions.config
# ===================================================================
# ALL global functions follows upper camel case.
# Global functions are vital for the configuration management.
#
# Copyright (c) 2020-2025 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="global-functions.config";
	"version"="0.7.0";
	"description"="Global functions are vital for the configuration management.";
	"global"=true;
	"global-functions"={
		"LoadGlobalEnv";
		"PrintGlobalEnv";
		"GetConfig";
		"UpdateConfig";
		"RegisterConfig";
		"CreateConfig";
		"RemoveConfig";
		"ListAllGlobals";
	};
};


# $LoadGlobalEnv
# Load global environments from an array and its source name(the config package name of that array),
# update global env info, and determine which env should be removed or added.
# TODO: suppress error, or it will be ambiguous for startup to print out the exact error.
# args: <str>                   <config package name>
# args: <array>                 <env array>
:global LoadGlobalEnv do={
	# global declare
	:global IsStrN;
	:global IsArray;
	:global IsNothing;
	:global GlobalEnvInfo;
	:global DumpVar;
	:global NewArray;
	:global GetCurrentDatetime;
	# check
	:if (![$IsStrN $1]) do={:error "Global.Config.LoadGlobalEnv: \$1 should be a string."}
	:if (![$IsArray $2]) do={:error "Global.Config.LoadGlobalEnv: \$2 should be an array."}
	# init global
	:if ([$IsNothing $GlobalEnvInfo]) do={
		:set GlobalEnvInfo {
			"data"=[$NewArray ];
			"configMapping"=[$NewArray ];
		}
	}
	# const
	:local pre "Env";
	# local
	:local pkgName $1;
	:local env $2;
	:local oldMeta (($GlobalEnvInfo->"configMapping")->$pkgName);
	:local vName;
	:if ([$IsNothing $oldMeta] and ([:len $env] = 0)) do={:return 0};
	:local metaDiff [$NewArray ];
	:if (![$IsNothing $oldMeta]) do={
		# old meta exist, update it
		:foreach k,v in $oldMeta do={
			:set ($metaDiff->$k) true;
		}
	}
	# prepare config mapping
	:local mp [$NewArray ];
	:foreach k,v in $env do={
		:set vName "$pre$k";
		# exist vName or new
		:if ($metaDiff->$vName) do={
			:set ($metaDiff->$vName) false;
			# update meta
			:set ((($GlobalEnvInfo->"data")->$vName)->"updateDT") [$GetCurrentDatetime];
		} else {
			# check same
			:if (![$IsNothing (($GlobalEnvInfo->"data")->$vName)]) do={
				:local ccn ((($GlobalEnvInfo->"data")->$vName)->"configName");
				:put "Same Env detected, the setter is: $ccn->$vName";
				:put "Current Env loading abort: $pkgName. You can manually update it and invoke:";
				:put "[\$RegisterConfig \"$pkgName\"] to load it again";
				:error "Global.Config.LoadGlobalEnv: env conflict."
			}
			# make meta
			:local meta {
				"envName"=$vName; "configName"=$pkgName; "name"=$k;
				"createDT"=[$GetCurrentDatetime ]; "updateDT"=[$GetCurrentDatetime ];
			};
			:set (($GlobalEnvInfo->"data")->$vName) $meta;
		}
		# do global
		:local funcStr [$DumpVar $vName $v Global=true];
		:local func [:parse $funcStr];
		:local result [$func ];
		# make config mapping
		:set ($mp->$vName) true;
	}
	# remove not exist env
	:foreach k,v in $metaDiff do={
		:if ($v) do={
			/system/script/environment/remove [/system/script/environment/find name=$k];
			# remove global info
			:set (($GlobalEnvInfo->"data")->$k);
		}
	}
	:if ([:len $mp] > 0) do={
		:set (($GlobalEnvInfo->"configMapping")->$pkgName) $mp;
	} else {
		:set (($GlobalEnvInfo->"configMapping")->$pkgName)
	}
}


# $PrintGlobalEnv
# Print out GlobalEnvInfo.
:global PrintGlobalEnv do={
	# global declare
	:global IsNothing;
	:global NewArray;
	:global Join;
	:global GlobalEnvInfo;
	# init global
	:if ([$IsNothing $GlobalEnvInfo]) do={:error "Global.Config.PrintGlobalEnv: \$GlobalEnvInfo not initialized."}
	# local
	:put "======================   GlobalEnvInfo   ======================";
	:foreach k,v in ($GlobalEnvInfo->"data") do={
		:put "$k:";
		:local name ($v->"name");
		:local configName ($v->"configName");
		:local createDT ($v->"createDT");
		:local updateDT ($v->"updateDT");
		:put "     name        is  $name";
		:put "     configName  is  $configName";
		:put ("     createDT    is  " . [$Join ", " $createDT]);
		:put ("     updateDT    is  " . [$Join ", " $updateDT]);
	}
	:put "----------------------   configMapping   ----------------------";
	:foreach k,v in ($GlobalEnvInfo->"configMapping") do={
		:put "$k:";
		:local envs [$NewArray ];
		:foreach kk,vv in $v do={:set ($envs->[:len $envs]) $kk}
		:local envsStr [$Join "; " $envs];
		:put "    $envsStr";
	}
}


# $GetConfig
# args: <str>                   <package name>
# return: <array->var>          config named array
:global GetConfig do={
	# global declare
	:global FindPackage;
	:global IsArrayN;
	:global ValidateMetaInfo;
	# local
	:local pkgName $1;
	:local idList [$FindPackage $pkgName];
	:if (![$IsArrayN $idList]) do={
		:error "Global.Package.GetConfig: config \"$pkgName\" not found.";
	}
	# parse code and get result;
	:local pSource [:parse [/system/script/get ($idList->0) source]];
	:local pkg [$pSource ];
	:local va {"name"=$pkgName;"type"="config"};
	:local vres [$ValidateMetaInfo ($pkg->"metaInfo") $va];
	:if (!($vres->"flag")) do={
		:put "There are some errors in the meta info, check it first!";
		:foreach reason in ($vres->"reasons") do={
			:put "  $reason";
		}
		:error "Global.Package.GetConfig: could not validate target package.";
	}
	:return $pkg;
}


# $UpdateConfig
# Update the configure script file with its name and target array.
# args: <str>                   <config package name>
# args: <array>                 config array
# opt kwargs: Output=<str>      output format: file(default), str, array
:global UpdateConfig do={
	# global declare
	:global Nil;
	:global IsStrN;
	:global IsArray;
	:global IsArrayN;
	:global NewArray;
	:global TypeofStr;
	:global ReadOption;
	:global DumpVar;
	:global Join;
	:global Replace;
	:global LoadGlobalEnv;
	:global FindPackage;
	:global GetConfig;
	:global ScriptLengthLimit;
	# check
	:if (![$IsStrN $1]) do={:error "Global.Package.UpdateConfig: \$1 should be a string"}
	:if (![$IsArrayN $2]) do={:error "Global.Package.UpdateConfig: \$2 should a k,v array"}
	# local
	:local pkgName $1;
	:local config [$GetConfig $pkgName];
	:local envConfig ($config->"environment");
	:local envInput ($2->"environment");
	:local fileName [$Replace $pkgName "." "_"];
	:local pOutput [$ReadOption $Output $TypeofStr "file"];
	:local pOwner [/system/script/get [/system/script/find name=$fileName] owner];
	:local LSL [$NewArray ];
	:local configArray {
		"metaInfo"="noquote:\$metaInfo";
	};
	# TODO: better clock info
	:local clock [/system/clock/print as-value];
	:local date ($clock->"date");
	:local time ($clock->"time");
	# update meta and dump it
	:local meta ($config->"metaInfo");
	:set ($meta->"last_modify") "$date $time";
	:set LSL ($LSL, [$DumpVar "metaInfo" $meta Output="array" Return=false]);
	:set ($LSL->[:len $LSL]) "";
	# update by input
	:foreach k,v in $2 do={
		:set ($config->$k) $v;
	}
	# dump addition array
	:foreach k,v in $config do={
		:if ([$IsArray $v]) do={
			:if ($k != "metaInfo") do={
				:set ($configArray->$k) "noquote:\$$k";
				:set LSL ($LSL, [$DumpVar $k $v Output="array" Return=false]);
				:set ($LSL->[:len $LSL]) "";
			}
		} else {
			:set ($configArray->$k) $v;
		}
	}
	# dump config array
	:set LSL ($LSL, [$DumpVar "config" $configArray Output="array"]);
	:set ($LSL->[:len $LSL]) "";
	# output array
	:if ($pOutput = "array") do={
		:return $LSL;
	}
	# join
	:local result [$Join ("\r\n") $LSL];
	# check script length
	:if ([:len $result] >= $ScriptLengthLimit) do={
		:error "Global.Package.UpdateConfig: configuration file length reachs 30,000 characters limit, try split it";
	}
	# output str
	:if ($pOutput = "str") do={
		:return $result;
	}
	# output file
	/system/script/set [$FindPackage $pkgName] source=$result owner=$pOwner;
	# load env into global
	:if ([$IsArrayN $envConfig] and [$IsArrayN $envInput]) do={
		:if ($envConfig != $envInput) do={
			[$LoadGlobalEnv $pkgName $envInput];
		}
		:return $Nil;
	}
	# only old config has env
	:if ([$IsArrayN $envConfig]) do={
		[$LoadGlobalEnv $pkgName [$NewArray ]];
	}
	# only new config has env
	:if ([$IsArrayN $envInput]) do={
		[$LoadGlobalEnv $pkgName $envInput];
	}
}


# $RegisterConfig
# Register manually added configuration package into base config.
# And load its environment into global.
# args: <str>                   <package name>
:global RegisterConfig do={
	# global declare
	:global IsArrayN;
	:global FindPackage;
	:global GetConfig;
	:global UpdateConfig;
	:global LoadGlobalEnv;
	# local
	:local pkgName $1;
	:local idList [$FindPackage $pkgName];
	:if (![$IsArrayN $idList]) do={:return 0};
	# register
	:local config [$GetConfig $pkgName];
	:local baseConfigName "config.rospm";
	# register into base config
	:if (($baseConfigName != $pkgName) and [$IsArrayN [$FindPackage $baseConfigName]]) do={
		:local baseConfig [$GetConfig $baseConfigName];
		:local configItem {
			"name"=$pkgName;
			"description"=$pDescription;
		};
		:local configID (($baseConfig->"configMapping")->$pkgName);
		:if (![$IsNothing $configID]) do={:return 0};
		# config name not exist, append it
		:set (($baseConfig->"configMapping")->$pkgName) [:len ($baseConfig->"configList")];
		:set (($baseConfig->"configList")->[:len ($baseConfig->"configList")]) $configItem;
		# do update
		[$UpdateConfig $baseConfigName $baseConfig];
		# load environment into global
		:if ([$IsArrayN ($config->"environment")]) do={
			[$LoadGlobalEnv $pkgName ($config->"environment")];
		}
	}
}


# $CreateConfig
# create a new configuration package.
# args: <str>                       <config package name>
# args: <array->str>                config array
# opt kwargs: Owner=<str>           script owner
# opt kwargs: Description=<str>     script description
# opt kwargs: Force=<bool>          remove existing file if true, default false
:global CreateConfig do={
	# global declare
	:global IsStrN;
	:global IsArray;
	:global IsArrayN;
	:global IsEmpty;
	:global IsNothing;
	:global Join;
	:global DumpVar;
	:global NewArray;
	:global TypeofStr;
	:global TypeofBool;
	:global FindPackage;
	:global GetConfig;
	:global UpdateConfig;
	:global LoadGlobalEnv;
	:global Replace;
	:global ReadOption;
	:global ScriptLengthLimit;
	# check
	:if (![$IsStrN $1]) do={:error "Global.Package.CreateConfig: \$1 should be a string"}
	:if (![$IsArrayN $2]) do={:error "Global.Package.CreateConfig: \$2 should be an array"}
	# local
	:local pkgName $1;
	:local config $2;
	:local baseConfigName "config.rospm";
	:local fileName [$Replace $pkgName "." "_"];
	:local pOwner [$ReadOption $Owner $TypeofStr ""];
	:local pDescription [$ReadOption $Description $TypeofStr "NO DESCRIPTION"];
	:local pForce [$ReadOption $Force $TypeofBool false];
	:local LSL [$NewArray ];
	:local configArray {
		"metaInfo"="noquote:\$metaInfo";
	};
	# TODO: better clock info
	:local clock [/system/clock/print as-value];
	:local date ($clock->"date");
	:local time ($clock->"time");
	# dump meta
	:local meta {
		"name"=$pkgName;
		"description"=$pDescription;
		"type"="config";
		"created_at"="$date $time";
		"last_modify"="$date $time";
	};
	:set LSL ($LSL, [$DumpVar "metaInfo" $meta Output="array" Return=false]);
	:set ($LSL->[:len $LSL]) "";
	# dump additions
	:foreach k,v in $config do={
		:if ([$IsArray $v]) do={
			:if ($k != "metaInfo") do={
				:set ($configArray->$k) "noquote:\$$k";
				:set LSL ($LSL, [$DumpVar $k $v Output="array" Return=false]);
				:set ($LSL->[:len $LSL]) "";
			}
		} else {
			:set ($configArray->$k) $v;
		}
	}
	# dump config
	:set LSL ($LSL, [$DumpVar "config" $configArray Output="array"]);
	:set ($LSL->[:len $LSL]) "";
	# output array
	:if ($pOutput = "array") do={
		:return $LSL;
	}
	# join
	:local result [$Join ("\r\n") $LSL];
	# check script length
	:if ([:len $result] >= $ScriptLengthLimit) do={
		:error "Global.Package.CreateConfig: configuration file length reachs 30,000 characters limit, try split it";
	}
	# make config file
	:if ($pForce) do={
		/system/script/remove [/system/script/find name=$fileName];
	} else {
		:if (![$IsEmpty [/system/script/find name=$fileName]]) do={
			:error "Global.Package.CreateConfig: same configuration file already exist!";
		}
	}
	:if ($pOwner = "") do={
		/system/script/add name=$fileName source=$result;
	} else {
		/system/script/add name=$fileName source=$result owner=$pOwner;
	}
	# load environment into global
	:if ([$IsArrayN ($config->"environment")]) do={
		[$LoadGlobalEnv $pkgName ($config->"environment")];
	}
	# register into base config
	:if (($baseConfigName != $pkgName) and [$IsArrayN [$FindPackage $baseConfigName]]) do={
		:local baseConfig [$GetConfig $baseConfigName];
		:local configItem {
			"name"=$pkgName;
			"description"=$pDescription;
		};
		:local configID (($baseConfig->"configMapping")->$pkgName);
		:if ([$IsNothing $configID]) do={
			# config name not exist, append it
			:set (($baseConfig->"configMapping")->$pkgName) [:len ($baseConfig->"configList")];
			:set (($baseConfig->"configList")->[:len ($baseConfig->"configList")]) $configItem;
		} else {
			# config name exist, update it
			:set (($baseConfig->"configList")->$configID) $configItem;
		}
		# do update
		[$UpdateConfig $baseConfigName $baseConfig];
	}
}


# $RemoveConfig
# Remove existing configuration package.
# args: <str>                       <config package name>
:global RemoveConfig do={
	# global declare
	:global IsStrN;
	:global IsArrayN;
	:global IsNothing;
	:global NewArray;
	:global FindPackage;
	:global LoadGlobalEnv;
	:global GetConfig;
	:global UpdateConfig;
	# check
	:if (![$IsStrN $1]) do={:error "Global.Package.RemoveConfig: \$1 should be a string"}
	# const
	:local baseConfigName "config.rospm";
	:local notAllowed {
		"config.rospm"=1;
		"config.rospm.package"=1;
		"config.rospm.package.ext"=1;
	}
	# local
	:local pkgName $1;
	:if (![$IsNothing ($notAllowed->$pkgName)]) do={
		:put "$pkgName is an essential configuration."
		:put "You can reset it with [[\$GetFunc \"rospm.reset.resetConfig\"]], but you should not remove it."
		:error "Global.Config.RemoveConfig: not allowed to remove."
	}
	# remove config
	/system/script/remove [$FindPackage $pkgName];
	# unregister env
	[$LoadGlobalEnv $pkgName [$NewArray ]];
	# unregister config
	:if ([$IsArrayN [$FindPackage $baseConfigName]]) do={
		:local baseConfig [$GetConfig $baseConfigName];
		# return if not found
		:if ([$IsNothing (($baseConfig->"configMapping")->$pkgName)]) do={:return 0};
		:local configList [$NewArray ];
		:local configMapping [$NewArray ];
		:local configName;
		:foreach v in ($baseConfig->"configList") do={
			:set configName ($v->"name");
			:if ($configName != $pkgName) do={
				:set ($configMapping->$configName) [:len $configArray];
				:set ($configList->[:len $configList]) $v;
			}
		}
		# update base config
		:set ($baseConfig->"configList") $configList;
		:set ($baseConfig->"configMapping") $configMapping;
		[$UpdateConfig $baseConfigName $baseConfig];
	}
}


# $ListAllGlobals
# List all existing global variables, global functions & envs.
:global ListAllGlobals do={
	# global declare
	:global IsNil;
	:global IsNothing;
	:global NewArray;
	:global LoadGlobalEnv;
	:global GetConfig;
	# const
	:local pkgConfigName "config.rospm.package";
	:local pkgExtConfigName "config.rospm.package.ext";
	:local pkgConfig [$GetConfig $pkgConfigName];
	:local pkgExtConfig [$GetConfig $pkgExtConfigName];
	# local
	:local globals [$NewArray ];    # const
	:local pre "Env";
	# environment
	:foreach k,v in ([$GetConfig "config.rospm"]->"environment") do={
		:set ($globals->[:len $globals]) ($pre . $k);
	}
	:foreach k,v in ($pkgConfig->"environment") do={
		:set ($globals->[:len $globals]) ($pre . $k);
	}
	:foreach k,v in ($pkgExtConfig->"environment") do={
		:set ($globals->[:len $globals]) ($pre . $k);
	}
	# package
	:foreach meta in ($pkgConfig->"packageList") do={
		:foreach gvn in ($meta->"global-variables") do={
			:set ($globals->[:len $globals]) $gvn;
		}
		:foreach gfn in ($meta->"global-functions") do={
			:set ($globals->[:len $globals]) $gfn;
		}
	}
	# package ext
	:foreach meta in ($pkgExtConfig->"packageList") do={
		:foreach gvn in ($meta->"global-variables") do={
			:set ($globals->[:len $globals]) $gvn;
		}
		:foreach gfn in ($meta->"global-functions") do={
			:set ($globals->[:len $globals]) $gfn;
		}
	}
	:return $globals;
}


# package info
:local package {
	"metaInfo"=$metaInfo;
}
:return $package;
