#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   tool.file
# ===================================================================
# ALL package level functions follows lower camel case.
# file utility
#
# Copyright (c) 2020-2025 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="tool.file";
	"version"="0.6.0";
	"description"="file utility";
};


# $create
# Only support create *.txt file.
# kwargs: Name=<str>                    file name
# return: <num>                         time cost
:local create do={
	#DEFINE global
	:global IsEmpty;
	:global IsStr;
	:global RSplit;
	# check
	:if (![$IsStr $Name]) do={
		:error "tool.file.create: require \$Name";
	}
	:if ($Name = "") do={
		:error "tool.file.create: empty \$Name";
	}
	:local splitted [$RSplit $Name "." 1];
	:local suffix [:pick $splitted ([:len $splitted] - 1)];
	:if ($suffix != "txt") do={
		:error "tool.file.create: only support create txt file currently.";
	}
	# local
	:local interval 200;
	:local timer 0;
	:local timerMax 5000;
	/file/print file=$Name;
	:while ($timer < $timerMax) do={
		:delay ("$interval" . "ms");
		:set timer ($timer + $interval)
		:if (![$IsEmpty [/file/find name=$Name]]) do={
			:return $timer;
		}
	}
	:error "tool.file.create: timeout";
}


# $createDir
# Create directory via fetch http://127.0.0.1/favicon.png into file.
# This function DOES NOT depends on whether /ip service www is enabled or not.
# This function will not raise error when folder already exist.
# kwargs: Name=<str>                    file name
:local createDir do={
	#DEFINE global
	:global IsEmpty;
	:global IsStr;
	# check
	:if (![$IsStr $Name]) do={
		:error "tool.file.createDir: require \$Name";
	}
	:if ($Name = "") do={
		:error "tool.file.createDir: empty \$Name";
	}
	# local
	:do {
		:local result [/tool/fetch "http://127.0.0.1/favicon.png" dst-path="$Name/tmp" as-value];
	} on-error={}
	:local idList [/file/find name="$Name/tmp"];
	:if (![$IsEmpty $idList]) do={
		/file/remove $idList;
	}
}


# $findFile
# Find files by name or regex.
# opt kwargs: Name=<str>                    file name
# opt kwargs: Regexp=<str>                  file regexp
# return: <array->str>                      file internal id array
:local find do={
	#DEFINE global
	:global IsNil;
	:global Replace;
	:global NewArray;
	:global TypeofStr;
	:global ReadOption;
	# read opt
	:local pName [$ReadOption $Name $TypeofStr];
	:local pRegexp [$ReadOption $Regexp $TypeofStr];
	# check
	:if ([$IsNil $pName] and [$IsNil $pRegexp]) do={
		:error "tool.file.find: need \$Name or \$Regexp";
	}
	# generate regex from name
	:if (![$IsNil $pName]) do={
		# check name, \_ represents whitespace
		:if (!($Name ~ "^([A-Za-z0-9_-]|\_)+(\\.[A-Za-z0-9]+)*\$")) do={
			:error "tool.file.find: \$Name should not contains special characters.";
		}
		# do escape
		:local escapeMap {
			"."=("\\.");
		};
		:local escaped $pName;
		:foreach k,v in $escapeMap do={
			:set escaped [$Replace $escaped $k $v];
		}
		:set pRegexp "^([^/]+/)*?$escaped\$";
	}
	:local idList [/file/find name~$pRegexp];
	:local nameList [$NewArray ];
	:foreach v in $idList do={
		:set ($nameList->[:len $nameList]) [/file/get $v name];
	}
	:return $nameList;
}


:local package {
	"metaInfo"=$metaInfo;
	"create"=$create;
	"createDir"=$createDir;
	"find"=$find;
}
:return $package;
