# prerequisite

{
    [[$GetFunc "rspm.install"] Package="global-helpers"];
    [[$GetFunc "rspm.install"] Package="interface.list"];
    [[$GetFunc "rspm.install"] Package="ip.address"];
    [[$GetFunc "rspm.install"] Package="ip.firewall.address"];
    [[$GetFunc "rspm.install"] Package="tool.remote"];
    [[$GetFunc "rspm.install"] Package="tool.template"];
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
