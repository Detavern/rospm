#!rsc by RouterOS
# ===================================================================
# |     Global Functions     |   global-functions.misc
# ===================================================================
# ALL global functions follows upper camel case.
# global functions for miscellaneous collection
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="global-functions.misc";
	"version"="0.6.0";
	"description"="global functions for miscellaneous collection";
	"global"=true;
	"global-functions"={
		"UniqueArray";
	};
};


# $UniqueArray
# let an array to be a unique one by values
# args: <array>                 target array
# return: <array>               array
:global UniqueArray do={
	# global declare
	:global NewArray;
	:global SimpleDump;
	:global SimpleLoad;
	# local
	:local mapped [$NewArray ];
	:local result [$NewArray ];
	# dump value and put it into map
	:foreach v in $1 do={
		# :put $v;
		:local key [$SimpleDump $v];
		:set ($mapped->$key) 1;
	}
	# load dumpped value
	:foreach k,v in $mapped do={
		:set result ($result, [$SimpleLoad $k])
	}
	:return $result;
}


# package info
:local package {
	"metaInfo"=$metaInfo;
}
:return $package;
