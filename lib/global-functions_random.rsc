#!rsc by RouterOS
# ===================================================================
# |     Global Functions     |   global-functions.random
# ===================================================================
# ALL global functions follows upper camel case.
# global functions for random related operation
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
# Reference from [GPLv3]https://github.dev/eworm-de/routeros-scripts/global-functions
:local metaInfo {
	"name"="global-functions.random";
	"version"="0.5.0";
	"description"="global functions for random related operation";
	"global"=true;
	"global-functions"={
		"Random20CharHex";
		"RandomNumber";
		"RandomChoice";
	};
};



# $Random20CharHex
# generate random 20 chars hex (0-9 and a-f)
# return: <str>                 random 20 char
:global Random20CharHex do={
	:return ([/certificate/scep-server/otp/generate minutes-valid=0 as-value]->"password");
}


# $RandomNumber
# generate random number from $1 to $2(both include)
# args: <num>                   x num(include)
# args: <num>                   y num(include)
# return: <num>                 random
:global RandomNumber do={
	#DEFINE global
	:global IsNothing;
	:global Random20CharHex;
	:global HexToNum;
	# local
	:local max 4294967295;
	:local x [:tonum $1];
	:local y [:tonum $2];
	:local d ($y - $x);
	:if ($d = 0) do={
		:return $x;
	}
	:if ($d < 0) do={
		:error "Global.RandomNumber: \$2 should bigger than \$1";
	}
	:if ($d > $max) do={
		:error "Global.RandomNumber: difference of \$1 and \$2 should smaller than 2^32";
	}
	:local r ([$HexToNum [:pick [$Random20CharHex ] 0 15]] % ($d + 1));
	:return ($r + $x);
}


# $RandomChoice
# randomly choose an item from array, return its key.
# args: <array>                 array to choice
# return: <array->key>          random key list
:global RandomChoice do={
	#DEFINE global
	:global IsEmpty;
	:global RandomNumber;
	# local
	:if ([$IsEmpty $1]) do={
		:error "Global.RandomChoice: \$1 shoud be a not empty array";
	}
	:local l [:len $1];
	:local i [$RandomNumber 0 ($l - 1)];
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
