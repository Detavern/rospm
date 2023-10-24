#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   ip.dhcp
# ===================================================================
# ALL package level functions follows lower camel case.
# DHCP client & server scripts are used to facilitate the IP allocation.
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
    "name"="ip.dhcp";
    "version"="0.5.1";
    "description"="DHCP client & server scripts are used to facilitate the IP allocation.";
};


# $ensureClient
# Make sure the target interface has a DHCP client, keep it disabled if it is already disabled.
# kwargs: Interface=<str>                   on which physical interface
# opt kwargs: AddDefaultRoute=<bool>        flag of default route
# opt kwargs: UsePeerDNS=<bool>             flag of peer dns
# opt kwargs: UsePeerNTP=<bool>             flag of peer ntp
:local ensureClient do={
    #DEFINE global
    :global IsNil;
    :global IsEmpty;
    :global TypeofStr;
    :global TypeofBool;
    :global ReadOption;
    # read opt
    :local pIntf [$ReadOption $Interface $TypeofStr];
    :local pRoute [$ReadOption $AddDefaultRoute $TypeofStr no];
    :local pPeerDNS [$ReadOption $UsePeerDNS $TypeofBool no];
    :local pPeerNTP [$ReadOption $UsePeerNTP $TypeofBool no];
    # check
    :if ([$IsNil $pIntf]) do={
        :error "ip.dhcp.ensureClient: require a target interface";
    }
    :if ([$IsEmpty [/interface/find name=$pIntf]]) do={
        :error "ip.dhcp.ensureClient: target interface not found";
    }
    # do
    :local idList [/ip/dhcp-client/find interface=$pIntf];
    :if ([$IsEmpty $idList]) do={
        /ip/dhcp-client/add interface=$pIntf \
            use-peer-dns=$pPeerDNS use-peer-ntp=$pPeerNTP add-default-route=$pRoute;
    }
}


# $ensureServer
# Make sure the target interface has a DHCP server, keep it disabled if it is already disabled.
# If address pool does not exist, it will be created automatically.
# If the DHCP network is not specified, it will be automatically created based on
# the first network of the interface. The network prefix of this interface must be lower than 
# or equal to /24 to ensure enough IP address space is available.
# kwargs: Name=<str>                    DHCP server name
# kwargs: Interface=<str>               on which underlying interface
# kwargs: AddressPool=<str>             client address pool name
# opt kwargs: Network=<str>             DHCP network like 192.168.0.0/24
# opt kwargs: LeaseTime=<str>           client lease time
# opt kwargs: Authoritative=<str>       authoritative value
:local ensureServer do={
    #DEFINE global
    :global IsNil;
    :global IsEmpty;
    :global InputV;
    :global StartsWith;
    :global GetFunc;
    :global TypeofStr;
    :global TypeofTime;
    :global ParseCIDR;
    :global GetAddressPool;
    :global ReadOption;
    # read opt
    :local pName [$ReadOption $Name $TypeofStr];
    :local pIntf [$ReadOption $Interface $TypeofStr];
    :local pAddressPool [$ReadOption $AddressPool $TypeofStr];
    :local pNetwork [$ReadOption $Network $TypeofStr];
    :local pLeaseTime [$ReadOption $LeaseTime $TypeofTime 00:10:00];
    :local pAuth [$ReadOption $Authoritative $TypeofStr "yes"];
    # check
    :if ([$IsNil $pName]) do={
        :error "ip.dhcp.ensureServer: require \$Name";
    }
    :if ([$IsNil $pIntf]) do={
        :error "ip.dhcp.ensureServer: require \$Interface";
    }
    :if ([$IsNil $pAddressPool]) do={
        :error "ip.dhcp.ensureServer: require \$AddressPool";
    }
    :if (![$IsNil $pNetwork]) do={
        :if ([$IsNil [$ParseCIDR $pNetwork]]) do={
            :error "ip.dhcp.ensureServer: \$Network should be valid ip-prefix";
        }
    }
    # set network by interface
    :local addresses [[$GetFunc "ip.address.find"] Interface=$pIntf Output="cidr"];
    :if ([:len $addresses] = 0) do={
        :error "ip.dhcp.ensureServer: interface not found or no address on it";
    }
    :local cidr;
    :local cflag true;
    :foreach v in $addresses do={
        :local parsed [$ParseCIDR $v];
        :if ($cflag and (($parsed->"prefix") <= 24)) do={
            :if ([$IsNil $pNetwork]) do={
                :set cidr $parsed;
                :set cflag false;
            } else {
                :local net (($parsed->"network") . ("/") . ($parsed->"prefix"));
                :if ($net = $pNetwork) do={
                    :set cidr $parsed;
                    :set cflag false;
                }
            }
        }
    }
    :if ($cflag) do={
        :error "ip.dhcp.ensureServer: interface found, but no available network on it";
    }
    # ensure network
    :local addr (($cidr->"network") . ("/") . ($cidr->"prefix"));
    :local idList [/ip/dhcp-server/network/find address=$addr];
    :if ([$IsEmpty $idList]) do={
        /ip/dhcp-server/network/add address=$addr gateway=[:tostr ($cidr->"ip")] \
            dns-server=[:tostr ($cidr->"ip")];
    }
    # ensure pool
    :local addrPool [$GetAddressPool $cidr 100 199];
    :local idList [/ip/pool/find name=$pAddressPool];
    :if ([$IsEmpty $idList]) do={
        /ip/pool/add name=$pAddressPool ranges=$addrPool;
    }
    # ensure server
    :local idList [/ip/dhcp-server/find name=$pName];
    :if ([$IsEmpty $idList]) do={
        /ip/dhcp-server/add name=$pName interface=$pIntf address-pool=$pAddressPool \
            lease-time=$pLeaseTime authoritative=$pAuth;
    }
}


:local package {
    "metaInfo"=$metaInfo;
    "ensureClient"=$ensureClient;
    "ensureServer"=$ensureServer;
}
:return $package;

