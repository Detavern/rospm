# global string

## ToUpper & ToLower

### upper
{
	:local s "abcdefg";
	:put [$ToUpper $s];
	:put [$ToLower $s];
}

## lower
{
	:local s "ABCDEFG";
	:put [$ToLower $s];
	:put [$ToUpper $s];
}

## QuoteString
{
	:put "testing QuoteString...";
	:global Assert;
	:global QuoteString;

	:local a "\\\"\$\r\n\t\v";
	:local qa [$QuoteString $a];
	:local va ":local a \"$qa\";\n:return \$a";
	:local fa [:parse $va];
	:local ra [$fa];

	$Assert (([$QuoteString ("\r\n\t\v")])=("\\r\\n\\t\\v")) "quote string failed at case 1";
	$Assert (([$QuoteString ("\\\"\$")])=("\\\\\\\"\\\$")) "quote string failed at case 2";
	$Assert ($a=$ra) "quote string failed at case 3";
}


## QuoteRegexMeta

### meta echo
{
	:local meta ("\\.+*\?()|[]{}^\$\_");
	:put [:len $meta];
	:for i from=0 to=([:len $meta] - 1) do={
		:put ("\"" . [:pick $meta $i] . "\"");
	}
}

### test escape

{
	:put ("\\ foobar"~"^\\\\ foo");
	# escaped dot check, negative
	:put (". foobar"~"^. foo");
	:put ("a foobar"~"^. foo");
	# escaped dot check, positive
	:put (". foobar"~"^\\. foo");
	:put ("a foobar"~"^\\. foo");
	# escaped special space
	:put (" foobar"~"^\_foo");
	:put ("_foobar"~"^\_foo");
	:put ("  foobar"~"^\_+foo");
}

### test quote meta

{
	:put [$QuoteRegexMeta "WAN -> IN |"];
	:put ("WAN -> IN | foo"~[$QuoteRegexMeta "WAN -> IN |"]);
}
