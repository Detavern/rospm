#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   ddns.ip.provider
# ===================================================================
# ALL package level functions follows lower camel case.
# Provides functions for obtaining IP addresses from various DDNS providers.
#
# Copyright (c) 2020-2025 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="ddns.ip.provider";
	"version"="0.7.0.a";
	"description"="Provides functions for obtaining IP addresses from various DDNS providers.";
};


# $getDefaultAPIGroupParams
# return: <api group>
:local getDefaultAPIGroupParams do={
	:local params {
		"siteList"={
			{
				"type"="text";
				"url"="https://ifconfig.io";
			}
			{
				"type"="json";
				"url"="https://whoer.net/resolve";
				"key"="client_ip";
			};
			{
				"type"="json";
				"url"="https://api.ipify.org?format=json";
				"key"="ip";
			};
			{
				"type"="json";
				"url"="https://api.myip.com";
				"key"="ip";
			};
			{
				"type"="json";
				"url"="http://ip-api.com/json/";
				"key"="query";
			};
		}
	};
	:return $params;
}


# $byInterface
# Get ip address by specific a interface.
# kwargs: Params=<array->str>               provider params
# return: <ip> or <ipv6>                    result
# Params example {
#     "interface"="<interface name>";
# }
:local byInterface do={
	#DEFINE global
	:global IsStrN;
	:global IsArrayN;
	:global IsEmpty;
	:global GetFunc;
	# local
	:if (![$IsArrayN $Params]) do={
		:error "ddns.ip.provider.byInterface: \$Params should be an array";
	}
	:local intfName ($Params->"interface");
	:if (![$IsStrN $intfName]) do={
		:error "ddns.ip.provider.byInterface: \$interface should be a string";
	}
	:local ipList [[$GetFunc "ip.address.find"] Interface=$intfName];
	:if ([$IsEmpty $ipList]) do={
		:error "ddns.ip.provider.byInterface: ip not found on interface";
	}
	:return ($ipList->0);
}


# $byHTTPGet
# Use external third party plain text API to fetch the real WAN ip address.
# kwargs: Params=<array->str>               provider params
# return: <ip> or <ipv6>                    result
# Params example {
#     "url"="<url>";
# }
:local byHTTPGet do={
	#DEFINE global
	:global IsNil;
	:global IsArrayN;
	:global GetFunc;
	:global Strip;
	# local
	:if (![$IsArrayN $Params]) do={
		:error "ddns.ip.provider.byHTTPGet: \$Params should be an array";
	}
	:local url ($Params->"url");
	:local resp [[$GetFunc "tool.http.httpGet"] URL=$url ];
	:local ipStr [$Strip ($resp->"data")];
	# result
	:local ip;
	:set ip [:toip $ipStr];
	:if (![$IsNil $ip]) do={
		:return $ip;
	}
	:set ip [:toip6 $ipStr];
	:if (![$IsNil $ip]) do={
		:return $ip;
	}
	:error "ddns.ip.provider.byHTTPGet: ip not found";
}


# $byHTTPGetJSON
# Use external third party JSON API to fetch the real WAN ip address.
# kwargs: Params=<array->str>               provider params
# return: <ip> or <ipv6>                    result
# Params example {
#     "url"="<url>";
#     "key"="<the json key of ip>";
# }
:local byHTTPGetJSON do={
	#DEFINE global
	:global IsNil;
	:global IsArrayN;
	:global GetFunc;
	# local
	:if (![$IsArrayN $Params]) do={
		:error "ddns.ip.provider.byHTTPGet: \$Params should be an array";
	}
	:local url ($Params->"url");
	:local resp [[$GetFunc "tool.http.httpGet"] URL=$url Output="json"];
	:local js ($resp->"json");
	:local ipStr ($js->($Params->"key"));
	# result
	:local ip;
	:set ip [:toip $ipStr];
	:if (![$IsNil $ip]) do={
		:return $ip;
	}
	:set ip [:toip6 $ipStr];
	:if (![$IsNil $ip]) do={
		:return $ip;
	}
	:error "ddns.ip.provider.byHTTPGetJSON: no ip found";
}


# $byAPIGroup
# Use external third party API Group to get the real WAN ip address.
# This function will randomly choose one api from api group and use that
# to get the external ip address.
# kwargs: Params=<array->str>               provider params
# return: <ip> or <ipv6>                    result
# Params example {
#     "siteList"={
#         { "type"="text"; "url"=<url>; };
#         { "type"="json"; "url"=<url>; "key"=<key>; };
#         { "type"="json"; "url"=<url>; "key"=<key>; };
#         ...
#     }
# }
:local byAPIGroup do={
	#DEFINE global
	:global IsNil;
	:global IsEmpty;
	:global TypeofArray;
	:global ReadOption;
	:global RandomChoice;
	:global GetFunc;
	# check
	:local params [$ReadOption $Params $TypeofArray];
	:if ([$IsNil $params]) do={
		:set params [[$GetFunc "ddns.ip.provider.getDefaultAPIGroupParams"]];
	}
	:if ([$IsEmpty ($params->"siteList")]) do={
		:error "ddns.ip.provider.byAPIGroup: \$Params->siteList should be not empty";
	}
	# randomly get one
	:local rk [$RandomChoice ($params->"siteList")];
	:local vParams (($params->"siteList")->$rk);
	:local vType ($vParams->"type");
	:if ($vType = "text") do={
		:local ip [[$GetFunc "ddns.ip.provider.byHTTPGet"] Params=$vParams];
		:return $ip;
	}
	:if ($vType = "json") do={
		:local ip [[$GetFunc "ddns.ip.provider.byHTTPGetJSON"] Params=$vParams];
		:return $ip;
	}
	:error "ddns.ip.provider.byAPIGroup: unknown params type: $vType";

}


:local package {
	"metaInfo"=$metaInfo;
	"getDefaultAPIGroupParams"=$getDefaultAPIGroupParams;
	"byInterface"=$byInterface;
	"byHTTPGet"=$byHTTPGet;
	"byHTTPGetJSON"=$byHTTPGetJSON;
	"byAPIGroup"=$byAPIGroup;
}
:return $package;
