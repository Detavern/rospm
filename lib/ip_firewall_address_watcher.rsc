#!rsc by RouterOS
# ===================================================================
# |       RSPM Packages      |   ip.firewall.address.watcher
# ===================================================================
# ALL package level functions follows lower camel case.
# 
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rspm/blob/master/LICENSE.md
#
:local metaInfo {
    "name"="ip.firewall.address.watcher";
    "version"="0.4.0";
    "description"="watch and store address on specific interface";
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
    :global EnvRSPMBaseURL;
    # read opt
    :if (![$IsStrN $EnvRSPMBaseURL]) do={:error "ip.firewall.address.watcher: \$EnvRSPMBaseURL is empty!"};
    :if ([$IsNil $Name]) do={:error "ip.firewall.address.watcher: require \$Name"};
    :if ([$IsNil $InterfaceList]) do={:error "ip.firewall.address.watcher: require \$InterfaceList"};
    :local pName [$ReadOption $Name $TypeofStr];
    :local pInterfaceList [$ReadOption $InterfaceList $TypeofStr];
    :local pInterval [$ReadOption $Interval $TypeofTime 00:00:15];
    # get remote resource
    :local startupName "RSPM_STARTUP";
    :local resURL ($EnvRSPMBaseURL . "templates/schedule_ip_firewall_address_watcher.rsc");
    :local scriptTemplate [[$GetFunc "tool.remote.loadRemoteSource"] URL=$resURL Normalize=true];
    # render
    :local v {
        "AddressList"=$pName;
        "InterfaceList"=$pInterfaceList;
    };
    :local scriptStr [[$GetFunc "tool.template.render"] Template=$scriptTemplate Variables=$v];
    # add schedule
    :local scheduleName ("RSPM_WATCHER_" . $pInterfaceList);
    :local scheduleComment ("rspm: watch ip change on interface list " . $pInterfaceList)

    /system/scheduler/remove [/system/scheduler/find name=$scheduleName];
    :put "Adding $startupName schedule...";
    # add scheduler use default policy
    :local id [/system/scheduler/add name=$scheduleName start-time=startup interval=$pInterval on-event=$scriptStr];
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
    :local scheduleName ("RSPM_WATCHER_" . $pInterfaceList);
    /system/scheduler/remove [/system/scheduler/find name=$scheduleName];
}


:local package {
    "metaInfo"=$metaInfo;
    "add"=$add;
    "delete"=$delete;
}
:return $package;