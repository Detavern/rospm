# /ip/route

## ensure

### ensure a route
{
    [[$GetFunc "ip.route.ensure"] Params=({"routing-table"="RT_SDN";})]
}

### ensure a route with comment
{
    [[$GetFunc "ip.route.ensure"] Params=({"routing-table"="RT_SDN"; "comment"="test comment";})]
}

### ensure a route use multiple lines
{
    [[$GetFunc "ip.route.ensure"] Params=({
        "dst-address"="0.0.0.0/0"; "gateway"="PPPoE_CLI_WAN_UNI";
        "routing-table"="RT_SDN"; "distance"=12})]

    [[$GetFunc "ip.route.ensure"] Params=({
        "dst-address"="0.0.0.0/0";
        "gateway"="PPPoE_CLI_WAN_UNI";
        "routing-table"="RT_SDN";
        "distance"=125;
        "comment"="testtset";
    })]
}

### extra gateway-address-list
{
    [[$GetFunc "ip.route.ensure"] Params=({
        "dst-address-list"="IP-CIDR_SDN";
        "gateway"="PPPoE_CLI_WAN_UNI";
        "routing-table"="RT_SDN";
        "distance"=12;
    })]
    [[$GetFunc "ip.route.ensure"] Params=({
        "dst-address-list"="IP-CIDR_SDN";
        "gateway-address-list"="IP_SELF_GW";
        "routing-table"="RT_SDN";
        "distance"=12;
    })]
}