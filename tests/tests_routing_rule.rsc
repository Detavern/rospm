# /routing/rule

## ensure

### ensure route if not exist
{
	:local params ({"dst-address"="1.0.0.2";"action"="lookup";"table"="main"});
	$Print [[$GetFunc "routing.rule.ensure"] Params=$params];
}

### ensure route when disabled
{
	:local params ({"dst-address"="0.0.0.0/8";"action"="lookup";"table"="main"});
	$Print [[$GetFunc "routing.rule.ensure"] Params=$params];
}

## ensureReserved
{
	[[$GetFunc "routing.rule.ensureReserved"]];
}
