#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   rospm.config
# ===================================================================
# ALL package level functions follows lower camel case.
# This package provides configuration management tools for ROSPM, including URL and version generation.
#
# Copyright (c) 2020-2025 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="rospm.config";
	"version"="0.7.0";
	"description"="This package provides configuration management tools for ROSPM, including URL and version generation.";
	"essential"=true;
	"global"=false;
};


# $generateBaseURL
# Generate base url by context.
# kwargs: Context=<array>       context comes from installer or others
# return: <str>                 base url
:local generateBaseURL do={
	#DEFINE GLOBAL
	:global IsNil;
	:global IsStr;
	:global TypeofArray;
	:global ReadOption;
	# check
	:local context [$ReadOption $Context $TypeofArray];
	:local repoType ($context->"ROSPMRepoType");
	:local repoName ($context->"ROSPMRepoName");
	:local proxy ($context->"ROSPMProxy");
	:if (![$IsStr $repoType]) do={
		:error "rospm.config.generateBaseURL: need ROSPMRepoType in \$Context";
	};
	:if (![$IsStr $repoName]) do={
		:error "rospm.config.generateBaseURL: need ROSPMRepoName in \$Context";
	};
	# github
	:if ($repoType = "github") do={
		:local branch ($context->"ROSPMBranch");
		:return ($proxy . "https://raw.githubusercontent.com/$repoName/$branch/");
	}
	# NOTE: add other types here
	# fallback
	:error "rospm.config.generateBaseURL: RepoType not recognized: $repoType";
}


# $generateVersionBaseURL
# Generate base url of version control by context.
# kwargs: Context=<array>       context comes from installer or others
# return: <str>                 base url of version control
:local generateVersionBaseURL do={
	#DEFINE GLOBAL
	:global IsNil;
	:global IsStr;
	:global TypeofArray;
	:global ReadOption;
	# check
	:local context [$ReadOption $Context $TypeofArray];
	:local repoType ($context->"ROSPMRepoType");
	:local repoName ($context->"ROSPMRepoName");
	:local version ($context->"ROSPMVersion");
	:local proxy ($context->"ROSPMProxy");
	:if (![$IsStr $repoType]) do={
		:error "rospm.config.generateVersionBaseURL: need ROSPMRepoType in \$Context";
	};
	:if (![$IsStr $repoName]) do={
		:error "rospm.config.generateVersionBaseURL: need ROSPMRepoName in \$Context";
	};
	:if (![$IsStr $version]) do={
		:error "rospm.config.generateVersionBaseURL: need ROSPMVersion in \$Context";
	};
	# github
	:if ($repoType = "github") do={
		:return ($proxy . "https://raw.githubusercontent.com/$repoName/v$version/");
	}
	# NOTE: add other types here
	# fallback
	:error "rospm.config.generateVersionBaseURL: RepoType not recognized: $repoType";
}


# $generateConfig
:local generateConfig do={
	#DEFINE GLOBAL
	:global NewArray;
	:global GetFunc;
	:global CreateConfig;
	# const
	:local configName "config.rospm";
	:local description "Auto-generated rospm base configuration.";
	:local environment {
		"GlobalCacheFuncEnabled"=false;
		"GlobalCacheFuncSize"=10;
	};
	:local configList {
		{
			"name"="config.rospm";
			"description"=$description;
		}
	}
	:local configMapping {
		"config.rospm"=0;
	}
	:local config {
		"environment"=$environment;
		"configList"=$configList;
		"configMapping"=$configMapping;
	}
	# make new config.rospm.package
	[$CreateConfig $configName $config Force=true \
		Owner="rospm" Description=$description];
	:put "Configuration: $configName initialized."
}


# $generatePackageConfig
# Generate package config by context and return modified context.
# kwargs: Context=<array>       context comes from installer or others
# return: <array>               modified context
:local generatePackageConfig do={
	#DEFINE GLOBAL
	:global IsNil;
	:global IsNothing;
	:global TypeofArray;
	:global ReadOption;
	:global NewArray;
	:global GetFunc;
	:global CreateConfig;
	# check
	:local context [$ReadOption $Context $TypeofArray];
	:if ([$IsNil $context]) do={:set context [$NewArray ]};
	# const
	:local configName "config.rospm.package";
	:local config {
		"environment"={
			"ROSPMRepoType"="github";
			"ROSPMRepoName"="Detavern/rospm";
			"ROSPMBranch"="master";
			"ROSPMOwner"="rospm";
			"ROSPMProxy"="";
		};
	}
	# update environment from context
	:foreach k,v in $context do={
		:set (($config->"environment")->$k) $v;
	}
	# add ROSPMBaseURL
	:if ([$IsNothing (($config->"environment")->"ROSPMBaseURL")]) do={
		:set (($config->"environment")->"ROSPMBaseURL") \
			[[$GetFunc "rospm.config.generateBaseURL"] Context=($config->"environment")];
	}
	# query remote version
	:local baseURL (($config->"environment")->"ROSPMBaseURL");
	:local resVersionURL ($baseURL . "res/version.rsc");
	:local resVersion [[$GetFunc "tool.remote.loadRemoteVar"] URL=$resVersionURL];
	# add ROSPMVersion as current version
	:set (($config->"environment")->"ROSPMVersion") $resVersion;
	:set (($config->"environment")->"ROSPMInfoVersion") $resVersion;
	:set (($config->"environment")->"ROSPMLatestVersion") $resVersion;
	# add ROSPMVersionBaseURL
	:if ([$IsNothing (($config->"environment")->"ROSPMVersionBaseURL")]) do={
		:set (($config->"environment")->"ROSPMVersionBaseURL") \
			[[$GetFunc "rospm.config.generateVersionBaseURL"] Context=($config->"environment")];
	}
	# load remote package info
	:local packageInfoURL ($baseURL . "res/package-info.rsc");
	:put "Get: $packageInfoURL";
	:local packageInfo [[$GetFunc "tool.remote.loadRemoteVar"] URL=$packageInfoURL];
	# update config
	:foreach k,v in $packageInfo do={
		:set ($config->$k) $v;
	}
	# make new config.rospm.package
	[$CreateConfig $configName $config \
		Force=true Owner=(($config->"environment")->"ROSPMOwner") \
		Description="Auto-generated rospm package configuration."];
	:put "Configuration: $configName initialized."
	:return ($config->"environment");
}


# $generatePackageExtConfig
# kwargs: Context=<array>       context comes from installer or others
:local generatePackageExtConfig do={
	#DEFINE GLOBAL
	:global IsNil;
	:global TypeofArray;
	:global ReadOption;
	:global NewArray;
	:global GetFunc;
	:global GetConfig;
	:global CreateConfig;
	# check
	:local context [$ReadOption $Context $TypeofArray];
	:if ([$IsNil $context]) do={:set context [$NewArray ]};
	# const
	:local configName "config.rospm.package.ext";
	:local config {
		"environment"=[$NewArray ];
	}
	# update environment
	:foreach k,v in $context do={
		:set (($config->"environment")->$k) $v;
	}
	:local environment ($config->"environment");
	# get package config
	:local configPkg [$GetConfig "config.rospm.package"];
	:local env ($configPkg->"environment");
	# load remote package info
	:local packageInfoURL (($env->"ROSPMBaseURL") . "res/package-info-ext.rsc");
	:put "Get: $packageInfoURL";
	:local packageInfo [[$GetFunc "tool.remote.loadRemoteVar"] URL=$packageInfoURL];
	# update config
	:foreach k,v in $packageInfo do={
		:set ($config->$k) $v;
	}
	# make new config.rospm.package
	[$CreateConfig $configName $config \
		Force=true Owner=($env->"ROSPMOwner") \
		Description="Auto-generated rospm package extension configuration."];
	:put "Configuration: $configName initialized."
}


# $updatePackageConfig
# Update package configurations based on incoming context.
# kwargs: Context=<array>       context
:local updatePackageConfig do={
	#DEFINE GLOBAL
	:global IsNil;
	:global IsNothing;
	:global TypeofArray;
	:global ReadOption;
	:global NewArray;
	:global GetFunc;
	:global GetConfig;
	:global UpdateConfig;
	# read opt
	:local context [$ReadOption $Context $TypeofArray [$NewArray ]];
	# const
	:local configName "config.rospm.package";
	:local config [$GetConfig $configName];
	# update environment from context
	:foreach k,v in $context do={
		:set (($config->"environment")->$k) $v;
	}
	# update ROSPMBaseURL
	:set (($config->"environment")->"ROSPMBaseURL") \
		[[$GetFunc "rospm.config.generateBaseURL"] Context=($config->"environment")];
	# update ROSPMVersionBaseURL
	:set (($config->"environment")->"ROSPMVersionBaseURL") \
		[[$GetFunc "rospm.config.generateVersionBaseURL"] Context=($config->"environment")];
	# update info version
	:if ([$IsNothing (($config->"environment")->"ROSPMInfoVersion")]) do={
		:set (($config->"environment")->"ROSPMInfoVersion") \
			(($config->"environment")->"ROSPMVersion");
	}
	# update latest version
	:if ([$IsNothing (($config->"environment")->"ROSPMLatestVersion")]) do={
		:set (($config->"environment")->"ROSPMLatestVersion") \
			(($config->"environment")->"ROSPMVersion");
	}
	# update
	[$UpdateConfig $configName ({"environment"=($config->"environment")})];
	:return ($config->"environment");
}


:local package {
	"metaInfo"=$metaInfo;
	"generateBaseURL"=$generateBaseURL;
	"generateVersionBaseURL"=$generateVersionBaseURL;
	"generateConfig"=$generateConfig;
	"generatePackageConfig"=$generatePackageConfig;
	"generatePackageExtConfig"=$generatePackageExtConfig;
	"updatePackageConfig"=$updatePackageConfig;
}
:return $package;
