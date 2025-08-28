# Important Tests

## nothing type
{
	:put "testing nothing...";
	:global Assert;
	:global Nothing;

	:local nothing;
	$Assert ($nothing=$Nothing) "something error";
}

### nothing & nil could not be used as key
{
	:put "testing nothing as key...";
	:global Assert;
	:global Nil;
	:global Nothing;

	:local mp {$Nothing="foo"; $Nil="bar"; "sth"="real"}
	$Assert (($mp->0) = false) "nothing as key error";
	$Assert (($mp->1) = false) "nil as key error";
}

### nothing & nil could be appeared as value
{
	:put "testing nothing as value...";
	:global Assert;
	:global Nil;
	:global Nothing;

	:local mp {"foo"=$Nothing; "bar"=$Nil; "sth"="real"}
	$Assert (($mp->"foo") = $Nothing) "nothing as value error";
	$Assert (($mp->"bar") = $Nil) "nil as value error";
}

## recover type
{
	:put "testing recover type...";
	:local srcV [$TypeRecovery "1.1.1.1/24"];
	:local dstV 1.1.1.1/24;
	$Assert ($srcV=$dstV) "recover type error";
}

## positional args
{
	:put "testing positional arguments...";
	:local v 1.1.1.1;
	:local Foo do={
		:local t1 [:typeof $1];
		:local t2 [:typeof $2];
		:local t3 [:typeof $3];
		$Assert ($t1=$TypeofIP) "t1 should be ip";
		$Assert ($t2=$TypeofStr) "t2 should be string";
		$Assert ($t3=$TypeofNothing) "t3 should be nothing";
	}

	[$Foo $v 1.1.1.1];
}

## keyword args
{
	:put "testing keyword arguments...";
	:local v 1.1.1.1;
	:local Foo do={
		:local t1 [:typeof $a];
		:local t2 [:typeof $b];
		:local t3 [:typeof $c];
		$Assert ($t1=$TypeofIP) "t1 should be ip";
		$Assert ($t2=$TypeofStr) "t2 should be string";
		$Assert ($t3=$TypeofNothing) "t3 should be nothing";
	}

	[$Foo a=$v b=1.1.1.1];
}

## array

### append an item

{
	:local foo {1;2;3};
	:local bar 4;
	:local alist ($foo, $bar);
	:put $alist;
}

### append an array

{
	:local foo {1;2;3};
	:local bar {4;5;6};
	:local alist ($foo, $bar);
	$Print $alist;
}

## closure

### negative
{
	:local modifyFlag false;
	:local Foo do={
		:set modifyFlag true;
	}
	[$Foo];
	:put $modifyFlag;
}

### positive in console, but negative in script
{
	:global TypeofStr;
	:global ReadOption;
	:local value [$ReadOption $NotExist $TypeofStr "foo"];
	:put "outsider: value is $value";
	:log warning "outsider: value is $value";
	:local Foo do={
		:local insideValue [$ReadOption $NotExistToo $TypeofStr "bar"];
		:put "insider: value is $insideValue";
		:log warning "insider: value is $insideValue";
	}
	[$Foo];
}

### positive in script
{
	:global TypeofStr;
	:global ReadOption;
	:local value [$ReadOption $NotExist $TypeofStr "foo"];
	:log warning "outsider: value is $value";
	:local Foo do={
		:global TypeofStr;
		:global ReadOption;
		:local insideValue [$ReadOption $NotExistToo $TypeofStr "bar"];
		:log warning "insider: value is $insideValue";
	}
	[$Foo];
}
