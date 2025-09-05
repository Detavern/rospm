#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   ddns.service.provider
# ===================================================================
# ALL package level functions follows lower camel case.
# Provides functions for updating IP records with DDNS service providers.
#
# Copyright (c) 2020-2025 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="ddns.service.provider";
	"version"="0.7.0";
	"description"="Provides functions for updating IP records with DDNS service providers.";
	"essential"=false;
	"global"=false;
};


# $logForDebug
# For debug use only. This function should not raise ANY exception,
# and the return value should obey the following structure.
# example return {
#     "result"="created";           created, updated, same, error
#     "advice"={
#         "some advice 1";
#         "some advice 2";
#     };
# }
# kwargs: IP=<ip>                           ip address or ipv6 address
# kwargs: Params=<array->str>               provider function params
:local logForDebug do={
	#DEFINE global
	:global IsNil;
	:global TypeofStr;
	:global TypeofArray;
	:global NewArray;
	:global ReadOption;
	# local
	:local vIP [$ReadOption $IP $TypeofStr];
	:local params [$ReadOption $Params $TypeofArray];
	:local adviceList [$NewArray ];
	:set ($adviceList->[:len $adviceList]) ("IP is $vIP");
	:foreach k,v in=$params do={
		:set ($adviceList->[:len $adviceList]) ("Param \"$k\" is \"$v\"");
	}
	:local result {
		"result"="created";
		"advice"=$adviceList;
	}
	:return $result;
}


# $byHTTPGet
# Update ip record by a HTTP Get API which use url, ip, token as params.
# kwargs: IP=<ip>                           ip address or ipv6 address
# kwargs: Params=<array->str>               provider function params
:local byHTTPGet do={
	#DEFINE global
	:global IsNil;
	:global TypeofStr;
	:global TypeofArray;
	:global GetFunc;
	:global ReadOption;
	:global Strip;
	# local
	:local vIP [$ReadOption $IP $TypeofStr];
	:local params [$ReadOption $Params $TypeofArray];
	:local url ($params->"url");
	:set ($params->"url");
	:set ($params->"ip") $vIP;
	:local resp [[$GetFunc "tool.http.httpGet"] URL=$url Params=$params DataType="text"];
	:local result {
		"result"="updated";
		"advice"=($resp->"data");
	}
	:return $result;
}


# $byHTTPPostJSON
# Update ip record by a HTTP Post API which use json string as data.
# Example JSON: {"ip": "", "token": "", "client_id": ""}
# kwargs: IP=<ip>                           ip address or ipv6 address
# kwargs: Params=<array->str>               provider function params
:local byHTTPPostJSON do={
	#DEFINE global
	:global IsNil;
	:global TypeofStr;
	:global TypeofArray;
	:global GetFunc;
	:global ReadOption;
	# local
	:local vIP [$ReadOption $IP $TypeofStr];
	:local params [$ReadOption $Params $TypeofArray];
	:local url ($params->"url");
	:set ($params->"url");
	:set ($params->"ip") $vIP;
	:set ($params->"client_id") [/system/identity/get name];
	:local resp [[$GetFunc "tool.http.httpPost"] URL=$url Data=$params DataType="json" Output="json"];
	:local result {
		"result"="updated";
		"advice"=($resp->"data");
	}
	:return $result;
}


:local package {
	"metaInfo"=$metaInfo;
	"logForDebug"=$logForDebug;
	"byHTTPGet"=$byHTTPGet;
	"byHTTPPostJSON"=$byHTTPPostJSON;
}
:return $package;
