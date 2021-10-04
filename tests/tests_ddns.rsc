## add schedule
{
    :local ipGetterParams {
        "interface"="ether1";
    };
    :local serviceProviderParams {
        "token"="abcdefghijklmn";
        "zoneName"="example.com";
        "recordName"="test.ddns";
    };
    [[$GetFunc "ddns.addSchedule"] \
        Name="TEST" \
        IPGetter="ddns.getter.getIPByInterface" IPGetterParams=$ipGetterParams \
        ServiceProvider="ddns.provider.cloudflare.ensureHostRecord" ServiceProviderParams=$serviceProviderParams \
    ];
}
