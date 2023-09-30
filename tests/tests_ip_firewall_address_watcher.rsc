# prerequisite

{
    [[$GetFunc "rospm.install"] Package="global-helpers"];
    [[$GetFunc "rospm.install"] Package="interface.list"];
    [[$GetFunc "rospm.install"] Package="ip.address"];
    [[$GetFunc "rospm.install"] Package="ip.firewall.address"];
    [[$GetFunc "rospm.install"] Package="tool.remote"];
    [[$GetFunc "rospm.install"] Package="tool.template"];
}

# add

## wan
{
    [[$GetFunc "ip.firewall.address.watcher.add"] Name="IP_WAN" InterfaceList="WAN"];
}

# delete

## wan
{
    [[$GetFunc "ip.firewall.address.watcher.delete"] InterfaceList="WAN"];
}
