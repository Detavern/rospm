# /ip/dhcp-client

## prerequisite
{
	[[$GetFunc "rospm.install"] Package="global-functions.network"];
	[[$GetFunc "rospm.install"] Package="ip.address"];
	[[$GetFunc "rospm.install"] Package="ip.pool"];
	[[$GetFunc "rospm.install"] Package="ip.dhcp.client"];
}

## ensure
{
	[[$GetFunc "ip.dhcp.client.ensure"] Params=({"interface"="BRG-LAN"})];
}
