# global runner

## RunCommand

{
	:local params [$NewArray];
	$Print [$RunCommand "/ip/address/find" $params];
}

{
	:local params {"interface"="ETH-1"};
	$Print [$RunCommand "/ip/address/find" $params];
}

{
	:local params {"interface"="!SUBS[/interface/list/member/get number=([find list=LAN_ETH]->0) interface]"};
	$Print [/ip/address/get [$RunCommand "/ip/address/find" $params]];
}


## ListAttributes

### list target attribute
{
	:local attrs [$ListAttributes "/ip/address" [/ip/address/find ] "network"];
	$Print $attrs;
}

### print all attributes
{
	:local attrs [$ListAttributes "/ip/address" [/ip/address/find ]];
	$Print $attrs;
}

## GetOrCreateEntity

{
	:local cmd "/interface/list/member";
	:local params {"list"="BACKUP";"interface"="ETH-1"};
	$Print [$GetOrCreateEntity $cmd $params];
}

{
	:local cmd "/interface/list/member";
	:local params {"list"="BACKUP";"interface"="ETH-1"};
	$Print [$GetOrCreateEntity $cmd $params Disabled=true];
}

{
	:local cmd "/interface/list/member";
	:local params {"list"="BACKUP";"interface"="ETH-1"};
	$Print [$GetOrCreateEntity $cmd $params Disabled=false];
}

## FindEntities

{
	:local filter {"interface"="ETH-1"};
	$Print [$FindEntities "/ip/address" $filter Attribute="network"];
}
