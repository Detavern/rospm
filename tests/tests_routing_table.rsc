# /routing/table

## ensure

### ensure table main
{
	$Print [[$GetFunc "routing.table.ensure"] Params=({"name"="main"})];
}

### ensure table test
{
	$Print [[$GetFunc "routing.table.ensure"] Params=({"name"="test"})];
}

### ensure table with fib disabled
{
	$Print [[$GetFunc "routing.table.ensure"] Params=({"name"="test";"!fib"=true})];
}
