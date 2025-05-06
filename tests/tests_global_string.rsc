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
