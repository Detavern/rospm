#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   ip.dhcp.server
# ===================================================================
# ALL package level functions follows lower camel case.
# This package provides functions to manage DHCP servers for IP allocation.
#
# Copyright (c) 2020-2025 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="ip.dhcp.server";
	"version"="0.7.0";
	"description"="This package provides functions to manage DHCP servers for IP allocation.";
};


# $ensureNetwork
# Ensure
# kwargs: Params=<params>
# params:
#   kwargs: address=<str>/<ip-prefix>
# If <cidr->ip> different from <cidr->network>, it will be used as the gateway.
#   opt kwargs: gateway=<str>, either gateway or gateway-offset should be specified
#   opt kwargs: gateway-offset=<num>, if both are not specified, use the first IP of the network
#   opt kwargs: is-gateway-dns=<bool>
#   opt kwargs: dns-server=<str>, use gateway if not specified and is-gateway-dns=true
:local ensureNetwork do={
	#DEFINE global
	:global IsNil;
	:global IsEmpty;
	:global IsNothing;
	:global TypeofArray;
	:global TypeofStr;
	:global TypeofNum;
	:global TypeofBool;
	:global ParseCIDR;
	:global ReadOption;
	:global GetOrCreateEntity;
	# read params
	:local params [$ReadOption $Params $TypeofArray];
	:if ([$IsNil $params]) do={
		:error "ip.dhcp.server.ensureNetwork: require \$Params"
	}
	:if ([$IsEmpty $params]) do={
		:error "ip.dhcp.server.ensureNetwork: require options in \$Params"
	}
	# read opt
	:if ([$IsNothing ($params->"address")]) do={
		:error "ip.dhcp.server.ensureNetwork: require address in \$Params"
	}
	:local net [:tostr ($params->"address")];
	:local cidr [$ParseCIDR $net];
	:if ([$IsNil $cidr]) do={
		:error "ip.dhcp.server.ensureNetwork: invalid address=$net in \$Params"
	}
	:set net (($cidr->"network") . "/" . ($cidr->"prefix"));
	:set ($params->"address") $net;
	# gateway
	:local gwOffset [$ReadOption ($params->"gateway-offset") $TypeofNum];
	:if (![$IsNil $gwOffset]) do={
		:set ($params->"gateway-offset");
		:set ($params->"gateway") (($cidr->"network") + $gwOffset);
	}
	:if ([$IsNothing ($params->"gateway")]) do={
		:if (($cidr->"network")!=($cidr->"ip")) do={
			:set ($params->"gateway") ($cidr->"ip");
		} else {
			:set ($params->"gateway") ($cidr->"first");
		}
	}
	# dns
	:local flagGwDns [$ReadOption ($params->"is-gateway-dns") $TypeofBool];
	:if (![$IsNil $flagGwDns]) do={
		:set ($params->"is-gateway-dns");
		:if ($flagGwDns) do={
			:set ($params->"dns-server") ($params->"gateway");
		}
	}
	# local
	:local iid [$GetOrCreateEntity "/ip/dhcp-server/network" \
		$params Filter=({"address"=$net})]
	:return $iid;
}


# $ensure
# Ensure the target interface has a DHCP server, leave it disabled if already disabled.
# If address pool does not exist, it will be created automatically.
# If the DHCP network is not specified, it will be automatically created based on
# the first network of the interface. The network prefix of this interface must be lower than
# or equal to /24 to ensure enough IP address space is available.
# kwargs: Params=<params>
# params:
#   kwargs: name=<str>
#   kwargs: interface=<str>
#   opt kwargs: address-pool=<str>
#   opt kwargs: lease-time=<time>
#   opt kwargs: authoritative=<str>
#   opt kwargs: use-reconfigure=<bool>
#   opt kwargs: network=<str>/<ip-prefix>
#   opt kwargs: network-config=<array->str>, config will be generated based on network if not specified
#   opt kwargs: pool-config=<array->str>, config will be generated based on network if not specified
#   opt kwargs: pool-prefix=<str>, use if network is specified
:local ensure do={
	#DEFINE global
	:global IsNil;
	:global IsEmpty;
	:global IsNothing;
	:global TypeofArray;
	:global TypeofStr;
	:global TypeofNum;
	:global GetFunc;
	:global ReadOption;
	:global GetOrCreateEntity;
	:global Print;
	# read params
	:local params [$ReadOption $Params $TypeofArray];
	:if ([$IsNil $params]) do={
		:error "ip.dhcp.server.ensure: require \$Params"
	}
	:if ([$IsEmpty $params]) do={
		:error "ip.dhcp.server.ensure: require options in \$Params"
	}
	# read opt
	:local pName [$ReadOption ($params->"name") $TypeofStr];
	:local pIntf [$ReadOption ($params->"interface") $TypeofStr];
	:if ([$IsNil $pName]) do={
		:error "ip.dhcp.server.ensure: require name in \$Params"
	}
	:if ([$IsNil $pIntf]) do={
		:error "ip.dhcp.server.ensure: require interface in \$Params"
	}
	:local idList [/interface/find name=$pIntf];
	:if ([$IsEmpty $idList]) do={
		:error "ip.dhcp.server.ensure: target interface=$pIntf not found";
	}
	# /ip/dhcp-server/network config
	:local netCfg [$ReadOption ($Params->"network-config") $TypeofArray];
	:if ([$IsNil $netCfg]) do={
		:if (![$IsNothing ($params->"network")]) do={
			:set netCfg {"address"=($params->"network")};
		} else {
			:error "ip.dhcp.server.ensure: require either network or network-config in \$Params"
		}
	} else {
		:set ($params->"network-config");
	}
	# /ip/pool config
	:local poolPrefix [$ReadOption ($Params->"pool-prefix") $TypeofStr];
	:if ([$IsNil $poolPrefix]) do={
		:set poolPrefix "POOL_";
	} else {
		:set ($params->"pool-prefix");
	}
	:local poolCfg [$ReadOption ($Params->"pool-config") $TypeofArray];
	:if ([$IsNil $poolCfg]) do={
		:if (![$IsNothing ($params->"network")]) do={
			:set poolCfg {
				"name"="$poolPrefix$pName";
				"network"=[:tostr ($params->"network")];
			};
		} else {
			:error "ip.dhcp.server.ensure: require either pool or pool-config in \$Params"
		}
	} else {
		:set ($params->"pool-config");
	}
	:if (![$IsNothing ($params->"network")]) do={
		:set ($params->"network");
	}
	# local
	[[$GetFunc "ip.dhcp.server.ensureNetwork"] Params=$netCfg];
	[[$GetFunc "ip.pool.ensure"] Params=$poolCfg];
	:set ($params->"address-pool") ($poolCfg->"name");
	:local iid [$GetOrCreateEntity "/ip/dhcp-server" \
		$params Filter=({"name"=($params->"name")})]
	:return $iid;
}


:local package {
	"metaInfo"=$metaInfo;
	"ensureNetwork"=$ensureNetwork;
	"ensure"=$ensure;
}
:return $package;
