#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   ddns.service.provider
# ===================================================================
# ALL package level functions follows lower camel case.
# The collections of ddns service providers
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
# Use cloudflare v4 api
:local metaInfo {
    "name"="ddns.service.provider";
    "version"="0.5.2";
    "description"="The collections of ddns service providers";
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
    :local result {
        "result"="created";
        "advice"={
            "IP is $IP";
            "Params are $Params";
        };
    }
    :return $result;
}


:local package {
    "metaInfo"=$metaInfo;
    "logForDebug"=$logForDebug;
}
:return $package;

