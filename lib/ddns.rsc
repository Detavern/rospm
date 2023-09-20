#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   ddns
# ===================================================================
# ALL package level functions follows lower camel case.
# ddns schedule framework
#
# Copyright (c) 2020-2021 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
    "name"="ddns";
    "version"="0.3.1";
    "description"="ddns schedule framework";
};


# $addSchedule
# kwargs: Name=<str>                                schedule name
# kwargs: IPGetter=<str>                            ip getter function path
# kwargs: IPGetterParams=<array->str>               ip getter function params
# kwargs: ServiceProvider=<str>                     service provider function path
# kwargs: ServiceProviderParams=<array->str>        service provider function params
# opt kwargs: Interval=<time>                       schedule interval(default: 00:03:00)
:local addSchedule do={
    #DEFINE global
    :global IsStrN;
    :global IsArray;
    :global TypeofTime;
    :global ReadOption;
    :global Replace;
    :global GetConfig;
    :global CreateConfig;
    :global GetFunc;
    # check
    :if (![$IsStrN $Name]) do={:error "ddns.addSchedule: \$Name should be a string"}
    :if (![$IsStrN $IPGetter]) do={:error "ddns.addSchedule: \$IPGetter should be a string"}
    :if (![$IsArray $IPGetterParams]) do={:error "ddns.addSchedule: \$IPGetterParams should be an array"}
    :if (![$IsStrN $ServiceProvider]) do={:error "ddns.addSchedule: \$ServiceProvider should be a string"}
    :if (![$IsArray $ServiceProviderParams]) do={:error "ddns.addSchedule: \$ServiceProviderParams should be an array"}
    :local pInterval [$ReadOption $Interval $TypeofTime 00:03:00];
    # const
    :local tmplName "schedule_ddns.rsc";
    :local rospmConfigName "config.rospm.package";
    :local configOwner "ddns";
    :local skdComment "managed by ddns";
    :local skdName "ddns_updater_$Name";
    # create config
    :local configName "config.ddns.schedule.$Name";
    :local config {
        "description"="auto generated ddns schedule configuration for $Name";
        "name"=$Name;
        "ipGetter"=$IPGetter;
        "ipGetterParams"=$IPGetterParams;
        "serviceProvider"=$ServiceProvider;
        "serviceProviderParams"=$ServiceProviderParams;
    }
    [$CreateConfig $configName $config Owner=$configOwner Force=true];
    # load remote template
    :local rospm [$GetConfig "config.rospm.package"];
    :local tmplUrl (($rospm->"baseURL") . "templates/$tmplName");
    :local content [[$GetFunc "tool.remote.loadRemoteSource"] URL=$tmplUrl Normalize=true];
    # TODO: maybe a template engine in the future?
    :set content [$Replace $content "{{ configName }}" $configName];
    # add schedule
    /system scheduler add name=$skdName comment=$skdComment \
        start-time=startup interval=$pInterval on-event=$content \
        policy=read,write,policy,test
}


:local package {
    "metaInfo"=$metaInfo;
    "addSchedule"=$addSchedule;
}
:return $package;
