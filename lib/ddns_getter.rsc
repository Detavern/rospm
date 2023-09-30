#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   ddns.getter
# ===================================================================
# ALL package level functions follows lower camel case.
# ddns ip getter
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
    "name"="ddns.getter";
    "version"="0.5.0";
    "description"="ddns ip getter";
};


# $getIPByInterface
# Get ip address by specific interface name
# kwargs: Params=<array->str>               getter params
# return: <ip> or <ipv6>                    result
# Params example {
#     "interface"="<interface name>";
# }
:local getIPByInterface do={
    #DEFINE global
    :global IsStrN;
    :global IsArrayN;
    :global GetFunc;
    # local
    :if (![$IsArrayN $Params]) do={
        :error "ddns.getter.getIPByInterface: \$Params should be an array";
    }
    :local intfName ($Params->"interface");
    :if (![$IsStrN $intfName]) do={
        :error "ddns.getter.getIPByInterface: \$interface should be a string";
    }
    :local ipList [[$GetFunc "ip.address.find"] Interface=$intfName];
    :return ($ipList->0);
}


# $getIPText
# Use external third party plain text API to fetch the real WAN ip address.
# kwargs: Params=<array->str>               getter params
# return: <ip> or <ipv6>                    result
# Params example {
#     "url"="<url>";
# }
:local getIPText do={
    #DEFINE global
    :global IsNil;
    :global GetFunc;
    :global Strip;
    # local
    :local url ($Params->"url");
    :local resp [[$GetFunc "tool.http.httpGet"] URL=$url ];
    :local ipStr [$Strip ($resp->"data")];
    # result
    :local ip;
    :set [:toip $ipStr];
    :if (![$IsNil $ip]) do={
        :return $ip;
    }
    :set [:toip6 $ipStr];
    :if (![$IsNil $ip]) do={
        :return $ip;
    }
    :error "ddns.getter.getIPText.<$url>: no ip";
}


# $getIPJson
# Use external third party JSON API to fetch the real WAN ip address.
# kwargs: Params=<array->str>               getter params
# return: <ip> or <ipv6>                    result
# Params example {
#     "url"="<url>";
#     "key"="<the json key of ip>";
# }
:local getIPJson do={
    #DEFINE global
    :global IsNil;
    :global GetFunc;
    # local
    :local url ($Params->"url");
    :local resp [[$GetFunc "tool.http.httpGet"] URL=$url Output="json"];
    :local js ($resp->"json");
    :local ipStr ($js->($Params->"key"));
    # result
    :local ip;
    :set [:toip $ipStr];
    :if (![$IsNil $ip]) do={
        :return $ip;
    }
    :set [:toip6 $ipStr];
    :if (![$IsNil $ip]) do={
        :return $ip;
    }
    :error "ddns.getter.getIPJson.<$url>: no ip";
}


# $getDefaultAPIGroupParams
# return: <api group>
:local getDefaultAPIGroupParams do={
    :local params {
        "siteList"={
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
            {
                "type"="json";
                "url"="https://api.my-ip.io/ip.json";
                "key"="ip";
            };
        }
    };
    :return $params;
}


# $getIPByAPIGroup
# Use external third party API Group to get the real WAN ip address.
# This function will randomly choose one api from api group and use that
# to get the external ip address.
# kwargs: Params=<array->str>               getter params
# return: <ip> or <ipv6>                    result
# Params example {
#     "siteList"={
#         { "type"="text"; "url"=<url>; };
#         { "type"="json"; "url"=<url>; "key"=<key>; };
#         { "type"="json"; "url"=<url>; "key"=<key>; };
#         ...
#     }
# }
:local getIPByAPIGroup do={
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
        :set params [[$GetFunc "ddns.getter.getDefaultAPIGroupParams"] ];
    }
    :if ([$IsEmpty ($params->"siteList")]) do={
        :error "ddns.getter.getIPByAPIGroup: \$Params->siteList should be not empty";
    }
    # randomly get one
    :local rk [$RandomChoice ($params->"siteList")];
    :local ip [[$GetFunc "ddns.getter.getIPJson"] Params=(($params->"siteList")->$rk)];
    :return $ip;
}


:local package {
    "metaInfo"=$metaInfo;
    "getIPByInterface"=$getIPByInterface;
    "getIPText"=$getIPText;
    "getIPJson"=$getIPJson;
    "getDefaultAPIGroupParams"=$getDefaultAPIGroupParams;
    "getIPByAPIGroup"=$getIPByAPIGroup;
}
:return $package;
