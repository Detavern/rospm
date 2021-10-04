:local metaInfo {
    "name"="tool.ddns";
    "version"="0.3.0";
    "description"="ddns schedule framework";
};


# $addSchedule
# kwargs: IPGetter=<str>                            ip getter function path
# kwargs: IPGetterParams=<array->str>               ip getter function params
# kwargs: ServiceProvider=<str>                     service provider function path
# kwargs: ServiceProviderParams=<array->str>        service provider function params
# opt kwargs: Interval=<time>               schedule interval(default: 00:03:00)
:local addSchedule do={
    #DEFINE global
    :global IsArray;
    :global IsStr;
    :global TypeofStr;
    :global TypeofTime;
    :global NewArray;
    :global Print;
    :global ReadOption;
    :global GetFunc;
    # local
    :local tmplName "schedule_tool_ddns.rsc";
    :local pInterval [$ReadOption $Interval $TypeofTime 00:03:00];
    :if (![$IsStr $Interface]) do={
        :error "tool.ddns.addSchedule: require \$Interface";
    }
    :local ipList [[$GetFunc "ip.address.find"] Interface=$Interface];
    $Print $ip;
    # op is str
    

}


:local package {
    "metaInfo"=$metaInfo;
    "addSchedule"=$addSchedule;
}
:return $package;
