#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   ddns
# ===================================================================
# ALL package level functions follows lower camel case.
# A simple ddns scheduler framework
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
    "name"="ddns";
    "version"="0.5.2";
    "description"="A simple ddns scheduler framework";
};


# $createConfig
# Create default config for ddns package.
:local createConfig do={
    #DEFINE global
    :global IsNil;
    :global CreateConfig;
    # env
    :global EnvROSPMOwner;
    # local
    :local configName "config.ddns";
    :local config {
        "scheduler"={};
    }
    :local description "Auto generated configuration working for ddns scheduler.";
    [$CreateConfig $configName $config Force=true \
        Owner=$EnvROSPMOwner Description=$description];
}


# $addScheduler
# kwargs: Name=<str>                                schedule name
# kwargs: IPProvider=<str>                          ip provider function path
# kwargs: IPProviderParams=<array->str>             ip provider function params
# kwargs: ServiceProvider=<str>                     service provider function path
# kwargs: ServiceProviderParams=<array->str>        service provider function params
# opt kwargs: Interval=<time>                       schedule interval(default: 00:03:00)
# opt kwargs: AlwaysUpdate=<bool>                   always update flag
:local addScheduler do={
    #DEFINE global
    :global TypeofBool;
    :global TypeofTime;
    :global IsStrN;
    :global IsEmpty;
    :global IsArray;
    :global ReadOption;
    :global FindPackage;
    :global GetConfig;
    :global UpdateConfig;
    :global GetFunc;
    # env
    :global EnvROSPMBaseURL;
    # check
    :if (![$IsStrN $Name]) do={:error "ddns.addSchedule: \$Name should be a string"}
    :if (![$IsStrN $IPProvider]) do={:error "ddns.addSchedule: \$IPProvider should be a string"}
    :if (![$IsArray $IPProviderParams]) do={:error "ddns.addSchedule: \$IPProviderParams should be an array"}
    :if (![$IsStrN $ServiceProvider]) do={:error "ddns.addSchedule: \$ServiceProvider should be a string"}
    :if (![$IsArray $ServiceProviderParams]) do={:error "ddns.addSchedule: \$ServiceProviderParams should be an array"}
    :local pInterval [$ReadOption $Interval $TypeofTime 00:01:00];
    :local pAlwaysUpdate [$ReadOption $AlwaysUpdate $TypeofBool false];
    # const
    :local tmplName "schedule_ddns.rsc";
    :local rospmConfigName "config.rospm.package";
    :local configName "config.ddns";
    :local scheduleComment "managed by ROSPM";
    :local scheduleName "DDNS_UPDATER_$Name";
    # create config
    :if ([$IsEmpty [$FindPackage $configName]]) do={
        [[$GetFunc "ddns.createConfig"]];
    }
    :local config [$GetConfig $configName];
    # update config
    :local cfgScheduler {
        "name"=$Name;
        "ipProvider"=$IPProvider;
        "ipProviderParams"=$IPProviderParams;
        "serviceProvider"=$ServiceProvider;
        "serviceProviderParams"=$ServiceProviderParams;
    }
    :set (($config->"scheduler")->$Name) $cfgScheduler;
    [$UpdateConfig $configName $config];
    # load remote template
    :local tmplUrl ($EnvROSPMBaseURL . "templates/$tmplName");
    :local content [[$GetFunc "tool.remote.loadRemoteSource"] URL=$tmplUrl Normalize=true];
    :local v {"schedulerName"=$Name;"alwaysUpdateFlag"=$pAlwaysUpdate};
    :set content [[$GetFunc "tool.template.render"] Template=$content Variables=$v];
    # add schedule
    /system/scheduler/add name=$scheduleName comment=$scheduleComment \
        start-time=startup interval=$pInterval on-event=$content;
}


:local package {
    "metaInfo"=$metaInfo;
    "createConfig"=$createConfig;
    "addScheduler"=$addScheduler;
}
:return $package;
