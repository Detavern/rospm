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
