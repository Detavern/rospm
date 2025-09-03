# global random

## RandomString
{
	:put [$RandomString];
	:put [$RandomString 20];
}

## RandomStringSymbol
{
	:put [$RandomStringSymbol];
	:put [$RandomStringSymbol 20];
}

## RandomNumber
{
	# both sides
	:put [:rndnum 0 100];
}

## RandomChoice
{
	:local a {apple="red"; banana="yellow"; grape="purple"; orange="orange"};
	:put [$RandomChoice $a];
}
