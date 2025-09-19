# global package

## CompareVersion
{
	:put "testing CompareVersion...";
	:global Assert;

	$Assert (([$CompareVersion "1.0.0" "1.0.0"])=0) "compare version failed at case 1";
	$Assert (([$CompareVersion "1.0.0.a" "1.0.0.a"])=0) "compare version failed at case 2";
	$Assert (([$CompareVersion "1.0.0" "1.1.0"])<0) "compare version failed at case 3";
	$Assert (([$CompareVersion "1.1.0" "1.0.0"])>0) "compare version failed at case 4";
	$Assert (([$CompareVersion "1.0.0.b" "1.0.0.a"])>0) "compare version failed at case 5";
	$Assert (([$CompareVersion "1.0.0" "1.0.0.a"])>0) "compare version failed at case 6";
	$Assert (([$CompareVersion "1.0.0.c" "1.0.0"])<0) "compare version failed at case 7";
	$Assert (([$CompareVersion "1.0.1.a" "1.0.0"])>0) "compare version failed at case 8";
}


## DumpVar
{
	:put "testing DumpVar...";
	:global Assert;
	:global DumpVar;

	:local a "hello \"world\"";
	:local fa [:parse [$DumpVar "v" $a]];
	:local b 123;
	:local fb [:parse [$DumpVar "v" $b]];
	:local c 255.255.255.255;
	:local fc [:parse [$DumpVar "v" $c]];
	:local d true;
	:local fd [:parse [$DumpVar "v" $d]];
	:local mp {"a"=123; "b"=0.0.0.0; "c"="foobar~\"foo\"";};
	:local fmp [:parse [$DumpVar "v" $mp]];

	$Assert ([$fa]=$a) "DumpVar failed at case 1";
	$Assert ([$fb]=$b) "DumpVar failed at case 2";
	$Assert ([$fc]=$c) "DumpVar failed at case 3";
	$Assert ([$fd]=$d) "DumpVar failed at case 4";
	$Assert ([$fmp]=$mp) "DumpVar failed at case 5";
}
