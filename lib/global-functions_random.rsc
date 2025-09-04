#!rsc by RouterOS
# ===================================================================
# |     Global Functions     |   global-functions.random
# ===================================================================
# ALL global functions follows upper camel case.
# This package provides global functions for generating random numbers and selections.
#
# Copyright (c) 2020-2025 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="global-functions.random";
	"version"="0.7.0.a";
	"description"="This package provides global functions for generating random numbers and selections.";
	"global"=true;
	"global-functions"={
		"RandomString";
		"RandomStringSymbol";
		"RandomChoice";
	};
};


# $RandomString
# args: <num>                   length of string
# return: <str>                 random string
:global RandomString do={
	#DEFINE global
	:global IsNil;
	:global IsNothing;
	# read opt
	:local strlen 16;
	:local strdict "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	:if (![$IsNothing $1]) do={
		:set strlen [:tonum $1];
	}
	:return [:rndstr length=$strlen from=$strdict];
}


# $RandomStringSymbol
# args: <num>                   length of string
# return: <str>                 random string
:global RandomStringSymbol do={
	#DEFINE global
	:global IsNil;
	:global IsNothing;
	# read opt
	:local strlen 16;
	:local strdict "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ~!@#\$%^&*()-=_+";
	:if (![$IsNothing $1]) do={
		:set strlen [:tonum $1];
	}
	:return [:rndstr length=$strlen from=$strdict];
}


# $RandomChoice
# randomly choose an item from array, return its key.
# args: <array>                 array to choice
# return: <array->key>          random key list
:global RandomChoice do={
	#DEFINE global
	:global IsEmpty;
	# local
	:if ([$IsEmpty $1]) do={
		:error "Global.RandomChoice: \$1 shoud be a not empty array";
	}
	:local l [:len $1];
	:local i [:rndnum 0 ($l - 1)];
	:local c 0;
	:foreach k,v in $1 do={
		:if ($c = $i) do={
			:return $k;
		} else {
			:set c ($c + 1);
		}
	}
}


# package info
:local package {
	"metaInfo"=$metaInfo;
}
:return $package;
