#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   rospm.feature
# ===================================================================
# ALL package level functions follows lower camel case.
# rospm feature tools
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="rospm.feature";
	"version"="0.6.0";
	"description"="rospm feature tools";
};

# $globalCacheFuncOn
# turn on global cache for functions
:local globalCacheFuncOn do={
	# global declare
	:global GetConfig;
	:global UpdateConfig;
	:global LoadGlobalEnv;
	# env
	:global EnvGlobalCacheFuncEnabled;
	# local
	:local configName "config.rospm";
	# enable
	:if (!$EnvGlobalCacheFuncEnabled) do={
		# update config and reload
		:local config [$GetConfig $configName];
		:set (($config->"environment")->"GlobalCacheFuncEnabled") true;
		[$UpdateConfig $configName $config];
		[$LoadGlobalEnv $configName ($config->"environment")];
	}
}


# $globalCacheFuncOff
# turn off global cache for functions
:local globalCacheFuncOff do={
	# global declare
	:global GetConfig;
	:global UpdateConfig;
	:global LoadGlobalEnv;
	# env
	:global EnvGlobalCacheFuncEnabled;
	# local
	:local configName "config.rospm";
	# disable
	:if ($EnvGlobalCacheFuncEnabled) do={
		# update config and reload
		:local config [$GetConfig $configName];
		:set (($config->"environment")->"GlobalCacheFuncEnabled") false;
		[$UpdateConfig $configName $config];
		[$LoadGlobalEnv $configName ($config->"environment")];
		# flush cache
		[$GlobalCacheFuncFlush ];
	}
}


:local package {
	"metaInfo"=$metaInfo;
	"globalCacheFuncOn"=$globalCacheFuncOn;
	"globalCacheFuncOff"=$globalCacheFuncOff;
}
:return $package;
