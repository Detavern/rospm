# prerequisite

{
    [[$GetFunc "rospm.install"] Package="global-helpers"];
    [[$GetFunc "rospm.install"] Package="global-functions.network"];
    [[$GetFunc "rospm.install"] Package="ip.address"];
    [[$GetFunc "rospm.install"] Package="ip.dhcp"];
}

## ensureClient

{
    [[$GetFunc "ip.dhcp.ensureClient"]];
    [[$GetFunc "ip.dhcp.ensureClient"] Interface="BRG-LAN"];

}

## ensureServer

{
    [[$GetFunc "ip.dhcp.ensureServer"]];
    [[$GetFunc "ip.dhcp.ensureServer"] Name="SERVER_DHCP_BRG-LAN" Interface="BRG-LAN" AddressPool="IP_POOL_DHCP_BRG-LAN"];
}
