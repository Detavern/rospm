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


## EnableOrCreateEntity

{
	:local cmd "/interface/list/member";
	:local params {"list"="BACKUP";"interface"="ETH-1"};
	$Print [$EnableOrCreateEntity $cmd $params];
}