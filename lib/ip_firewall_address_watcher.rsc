#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   ip.firewall.address.watcher
# ===================================================================
# ALL package level functions follows lower camel case.
# This package provides tools to watch and store addresses on specific interfaces using scheduled tasks.
#
# Copyright (c) 2020-2025 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="ip.firewall.address.watcher";
	"version"="0.7.0.a";
	"description"="This package provides tools to watch and store addresses on specific interfaces using scheduled tasks.";
};


# $add
# kwargs: Name=<str>                    address list name
# kwargs: InterfaceList=<str>           interface list name
# opt kwargs: Interval=<time>           schedule interval(default: 00:00:15)
# return: <id>
:local add do={
	#DEFINE global
	:global IsNil;
	:global IsStrN;
	:global TypeofStr;
	:global TypeofTime;
	:global ReadOption;
	:global GetFunc;
	# env
	:global EnvROSPMBaseURL;
	# read opt
	:if (![$IsStrN $EnvROSPMBaseURL]) do={:error "ip.firewall.address.watcher: \$EnvROSPMBaseURL is empty!"};
	:if ([$IsNil $Name]) do={:error "ip.firewall.address.watcher: require \$Name"};
	:if ([$IsNil $InterfaceList]) do={:error "ip.firewall.address.watcher: require \$InterfaceList"};
	:local pName [$ReadOption $Name $TypeofStr];
	:local pInterfaceList [$ReadOption $InterfaceList $TypeofStr];
	:local pInterval [$ReadOption $Interval $TypeofTime 00:00:15];
	# add a placeholder for pName
	:local placeholder {"127.1.1.1"};
	[[$GetFunc "ip.firewall.address.ensureAddressList"] List=$pName AddressList=$placeholder];
	# get remote resource
	:local resURL ($EnvROSPMBaseURL . "templates/schedule_ip_firewall_address_watcher.rsc");
	:local scriptTemplate [[$GetFunc "tool.remote.loadRemoteSource"] URL=$resURL Normalize=true];
	# render
	:local v {
		"AddressList"=$pName;
		"InterfaceList"=$pInterfaceList;
	};
	:local scriptStr [[$GetFunc "tool.template.render"] Template=$scriptTemplate Variables=$v];
	# add schedule
	:local scheduleName ("ROSPM_WATCHER_" . $pInterfaceList);
	:local scheduleComment "managed by ROSPM";

	/system/scheduler/remove [/system/scheduler/find name=$scheduleName];
	:put "Adding $scheduleName schedule...";
	# add scheduler use default policy
	:local id [/system/scheduler/add name=$scheduleName comment=$scheduleComment \
		start-time=startup interval=$pInterval on-event=$scriptStr];
	:return $id;
}


# $delete
# kwargs: InterfaceList=<str>           interface list name
# return: <id>
:local delete do={
	#DEFINE global
	:global IsNil;
	:global TypeofStr;
	:global ReadOption;
	# read opt
	:if ([$IsNil $InterfaceList]) do={:error "ip.firewall.address.watcher: require \$InterfaceList"};
	:local pInterfaceList [$ReadOption $InterfaceList $TypeofStr];
	# delete
	:local scheduleName ("ROSPM_WATCHER_" . $pInterfaceList);
	/system/scheduler/remove [/system/scheduler/find name=$scheduleName];
}


:local package {
	"metaInfo"=$metaInfo;
	"add"=$add;
	"delete"=$delete;
}
:return $package;
