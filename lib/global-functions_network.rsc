#!rsc by RouterOS
# ===================================================================
# |     Global Functions     |   global-functions.network
# ===================================================================
# ALL global functions follows upper camel case.
# Global functions aim at network calcuation.
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
# New structure
# <CIDR> array
# {
#     "cidr"="<ip-prefix>";
#     "ip"=<ip>;
#     "prefix"=<num>;
#     "subnet"=<ip>;
#     "wildcard"=<ip>;
#     "network"=<ip>;
#     "boardcast"=<ip>;
#     "first"=<ip>;
#     "last"=<ip>;
#     "total"=<num>;
#     "usable"=<num>;
# }
#
:local metaInfo {
    "name"="global-functions.network";
    "version"="0.5.1";
    "description"="Global functions are designed to perform network calcuation.";
    "global"=true;
    "global-functions"={
        "ToIPPrefix";
        "ParseCIDR";
    };
};

# $ToIPPrefix
# Convert string to ip-prefix. Return nil if not ip-prefix.
:global ToIPPrefix do={
    # global declare
    :global Nil;
    :global IsNil;
    :global IsStr;
    :global IsIPPrefix;
    # do
    :if ([$IsIPPrefix $1]) do={
        :return $1;
    }
    :if (![$IsStr $1]) do={
        :return $Nil;
    }
    :local v $1;
    :local pt "^([0-9]{1,3}\\.){3}[0-9]{1,3}\$";
    :local ptp "^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}\$";
    :if (!($v ~ $ptp)) do={
        :if ($v ~ $pt) do={
            :set v ("$v/32");
        } else {
            :return $Nil;
        }
    }
    :local result [[:parse ":return $v"]];
    :if (![$IsIPPrefix $result]) do={
        :return $Nil;
    }
    :return $result;
} 

# $IsCIDR
# args: <var>                   <CIDR>
# return: <bool>                flag
:global IsCIDR do={
    # global declare
    :global InKeys;
    :global TypeofArray;
    # check
    :if ([:typeof $1] != $TypeofArray) do={
        :return false;
    }; 
}

# $ParseCIDR
# Parse a string, ipv4, ipv4 prefix into CIDR. Return nil if not CIDR.
# args: <var>                   ip, ip-prefix, str
# return: <CIDR> or nil         CIDR
:global ParseCIDR do={
    # global declare
    :global Nil;
    :global IsNil;
    :global IsStr;
    :global IsIP;
    :global IsIPPrefix;
    :global ToIPPrefix;
    :global RSplit;
    # local
    :local cidr $Nil;
    # parse cidr
    :if ([$IsIP $1]) do={
        :set cidr [$ToIPPrefix ("$1/32")];
    }
    :if ([$IsIPPrefix $1]) do={
        :set cidr $1;
    }
    :if ([$IsStr $1]) do={
        :set cidr [$ToIPPrefix $1];
    }
    :if ([$IsNil $cidr]) do={
        :return $Nil;
    }
    # parse property
    :local result {"cidr"=$cidr};
    :local splitted [$RSplit [:tostr $cidr] "/" 1];
    :set ($result->"ip") [:toip ($splitted->0)];
    :set ($result->"prefix") [:tonum ($splitted->1)];
    :set ($result->"subnet") (255.255.255.255<<(32 - ($result->"prefix")));
    :set ($result->"wildcard") (~($result->"subnet"));
    :set ($result->"network") (($result->"ip") & ($result->"subnet"));
    :set ($result->"broadcast") (($result->"ip") | ($result->"wildcard"));
    :set ($result->"first") (($result->"network") + 1 - (($result->"prefix") / 31));
    :set ($result->"last") (($result->"broadcast") - 1 + (($result->"prefix") / 31));
    :set ($result->"total") ([:tonum ($result->"wildcard")] + 1);
    :set ($result->"usable") (($result->"last") - ($result->"first") + 1);
    :return $result;
}

# package info
:local package {
    "metaInfo"=$metaInfo;
}
:return $package;

