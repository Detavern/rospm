# global array

## Append
{
	:local a {1;2;3};
	:local b [$Append $a 4];
	# source & new should be different
	:put ("source: " . [:tostr $a]);
	:put ("new: " . [:tostr $b]);
}

## Prepend
{
	:local a {1;2;3};
	:local b [$Prepend $a 4];
	# source & new should be different
	:put ("source: " . [:tostr $a]);
	:put ("new: " . [:tostr $b]);
}

## GetKeys
{
	:local a {"a"="foo"; "b"="bar"; "c"="foobar"};
	:put [$GetKeys $a];
}
{
	:local a {1;2;3;4};
	:put [$GetKeys $a];
}

## IsSubset

### positive
{
	:local a {1;2;3};
	:local b {1;2;3;4};
	:put [$IsSubset $a $b];
}
{
	:local a {1;2;3};
	:local b {1;2;3};
	:put [$IsSubset $a $b];
}
{
	:local a [$NewArray ];
	:local b {1;2;3};
	:put [$IsSubset $a $b];
}

### negative
{
	:local a {1;2;3};
	:local b {1;2;4;5};
	:put [$IsSubset $a $b];
}
{
	:local a {1;2;3};
	:local b [$NewArray ];
	:put [$IsSubset $a $b];
}
