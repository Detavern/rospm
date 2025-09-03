# /ip/dhcp-server

## prerequisite
{
	[[$GetFunc "rospm.install"] Package="global-functions.network"];
	[[$GetFunc "rospm.install"] Package="ip.address"];
	[[$GetFunc "rospm.install"] Package="ip.pool"];
	[[$GetFunc "rospm.install"] Package="ip.dhcp.client"];
}

## ensureNetwork

### create
{
	[[$GetFunc "ip.dhcp.server.ensureNetwork"] Params=({"address"=10.0.0.0/24})];
}

### gateway is dns server
{
	[[$GetFunc "ip.dhcp.server.ensureNetwork"] Params=({"address"="10.0.0.0/24";"is-gateway-dns"=true})];
}

### update
{
	[[$GetFunc "ip.dhcp.server.ensureNetwork"] Params=({
		"address"=10.0.0.0/24;
		"gateway-offset"=254;
	})];
}

## ensure

### create
{
	[[$GetFunc "ip.dhcp.server.ensure"] Params=({
		"name"="TEST_DHCP";"interface"="ETH-1";"network"=10.0.0.254/24;
	})];
}

### create use full params
{
	[[$GetFunc "ip.dhcp.server.ensure"] Params=({
		"name"="TEST_DHCP";
		"interface"="ETH-1";
		"lease-time"=00:10:00;
		"use-reconfigure"=yes;
		"network-config"=({"address"="10.0.0.0/24";"is-gateway-dns"=true});
		"pool-config"=({"name"="TEST_POOL";"network"="10.0.0.0/24"});
	})];
}
