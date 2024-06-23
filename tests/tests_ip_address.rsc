# /ip address
## get address
:put [[$GetFunc "ip.address.find"] Interface="ETH-1"];
{
    :local intfList {"ETH-1"; "ETH-2"};
    :put [[$GetFunc "ip.address.find"] InterfaceList=$intfList];
}
:put [[$GetFunc "ip.address.find"] InterfaceList="WAN"];

## wait and find
:put [[$GetFunc "ip.address.waitAndFind"] Interface="ETH-1"];
