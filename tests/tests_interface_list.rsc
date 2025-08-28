# /interface/list

## ensure
:put [[$GetFunc "interface.list.ensure"] Name="WAN"];

## ensureInclude
{
	:local includeList {"WAN_ETH"; "WAN_PPP"; "WAN_VPN"};
	:put [[$GetFunc "interface.list.ensureListInclude"] List="WAN" includeList=$includeList];
}

### negative
{
	:local includeList {"all"};
	:put [[$GetFunc "interface.list.ensureListInclude"] List="NOT_EXIST" includeList=$includeList];
}
{
	:local includeList {"NOT_EXIST"};
	:put [[$GetFunc "interface.list.ensureListInclude"] List="WAN" includeList=$includeList];
}

## ensureExclude
{
	:local excludeList {"WAN_ETH"; "WAN_PPP"; "WAN_VPN"};
	:put [[$GetFunc "interface.list.ensureListExclude"] List="WAN" excludeList=$excludeList];
}

### negative
{
	:local excludeList {"all"};
	:put [[$GetFunc "interface.list.ensureListExclude"] List="NOT_EXIST" excludeList=$excludeList];
}
{
	:local excludeList {"NOT_EXIST"};
	:put [[$GetFunc "interface.list.ensureListExclude"] List="WAN" excludeList=$excludeList];
}

## ensureMembers
{
	:local intfList {"ETH-1"; "ETH-2"};
	:put [[$GetFunc "interface.list.ensureMembers"] List="WAN_ETH" Interfaces=$intfList];
}

### negative
{
	:local intfList {"ETH-1"; "ETH-2"};
	:put [[$GetFunc "interface.list.ensureMembers"] List="NOT_EXIST" Interfaces=$intfList];
}
{
	:local intfList {"NOT_EXIST"};
	:put [[$GetFunc "interface.list.ensureMembers"] List="NOT_EXIST" Interfaces=$intfList];
}

## findMembers
{
    :put [[$GetFunc "interface.list.findMembers"] Name="WAN"];
}

