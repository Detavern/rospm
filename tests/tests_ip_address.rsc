# /ip/address

## find

### get address by interface
:put [[$GetFunc "ip.address.find"] Interface="ETH-1"];

### get address by interface list

:put [[$GetFunc "ip.address.find"] InterfaceList="WAN"];

## wait and find
:put [[$GetFunc "ip.address.waitAndFind"] Interface="ETH-1"];
