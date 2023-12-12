## ip provider

{
    :local params {"interface"="BRG-LAN"};
    :put [[$GetFunc "ddns.ip.provider.byInterface"] Params=$params];
}

{
    :local params {"url"="https://ipconfig.io"};
    :put [[$GetFunc "ddns.ip.provider.byHTTPGet"] Params=$params];
}

{
    :local params {"url"="http://ip-api.com/json/";"key"="query"};
    :put [[$GetFunc "ddns.ip.provider.byHTTPGetJSON"] Params=$params];
}

{
    :local params {"interface"="BRG-LAN"};
    :put [[$GetFunc "ddns.ip.provider.byAPIGroup"] ];
}

## service provider

{
    :local params {
        "token"="THIS IS A DEBUG TOKEN";
        "zoneName"="THIS IS A DEBUG ZONE";
        "recordName"="THIS IS A DEBUG RECORD";
    };
    :local result [[$GetFunc "ddns.service.provider.logForDebug"] IP="1.1.1.1" Params=$params];
    :put ($result->"result");
    :put ($result->"advice");
}

## debug
{
    :local ipProviderParams {
        "interface"="BRG-LAN";
    };
    :local serviceProviderParams {
        "token"="THIS IS A DEBUG TOKEN";
        "zoneName"="THIS IS A DEBUG ZONE";
        "recordName"="THIS IS A DEBUG RECORD";
    };
    [[$GetFunc "ddns.addScheduler"] \
        Name="TEST" \
        IPProvider="ddns.ip.provider.byInterface" IPProviderParams=$ipProviderParams \
        ServiceProvider="ddns.service.provider.logForDebug" ServiceProviderParams=$serviceProviderParams \
    ];
}


## add schedule
{
    :local ipProviderParams {
        "interface"="ether1";
    };
    :local serviceProviderParams {
        "token"="abcdefghijklmn";
        "zoneName"="example.com";
        "recordName"="test.ddns";
    };
    [[$GetFunc "ddns.addScheduler"] \
        Name="TEST" \
        IPProvider="ddns.ip.provider.byInterface" IPProviderParams=$ipProviderParams \
        ServiceProvider="ddns.service.provider.cloudflare.ensureHostRecord" ServiceProviderParams=$serviceProviderParams \
    ];
}
